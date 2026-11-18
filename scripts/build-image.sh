#!/usr/bin/env bash
# Build a sheng disk image and extract the raw ext4 root partition.
# Usage: scripts/build-image.sh images/single-tty.scm [out-prefix]
set -euo pipefail
GUIX=${GUIX:-guix}
repo=$(cd "$(dirname "$0")/.." && pwd)
src=$1
prefix=${2:-$(basename "$src" .scm)}
# -L lets the image files use the repo's (packages ...) and (modules ...).
if ! out=$("$GUIX" system image --verbosity=2 -L "$repo" "$src" 2>"$prefix.err"); then
  echo "guix system image failed: $src" >&2
  tail -60 "$prefix.err" >&2
  while IFS= read -r logfile; do
    if test -r "$logfile"; then
      echo "Build log: $logfile" >&2
      gzip -dc -- "$logfile" | tail -120 >&2 || true
    elif [[ ${GITHUB_ACTIONS:-} == true ]]; then
      sudo gzip -dc -- "$logfile" | tail -120 >&2 || true
    fi
  done < <(grep "View build log at" "$prefix.err" | grep -oE "/var/log/guix/drvs/[[:alnum:]/_.-]+\.drv\.gz" | sort -u)
  exit 1
fi
disk=$(printf '%s\n' "$out" | tail -1)
test -f "$disk" || { echo "no disk image from guix: $disk" >&2; exit 1; }
echo "disk image: $disk"
# Read the actual partition layout. genimage may align it differently.
layout=$(LC_ALL=C parted -sm "$disk" unit B print)
root=$(printf '%s\n' "$layout" | awk -F: '$1 ~ /^[0-9]+$/ && $5 == "ext4" {print $2, $4}')
if [[ ! "$root" =~ ^([0-9]+)B[[:space:]]+([0-9]+)B$ ]]; then
  echo "Expected exactly one ext4 partition in $disk" >&2
  printf '%s\n' "$layout" >&2
  exit 1
fi
start=${BASH_REMATCH[1]}
size=${BASH_REMATCH[2]}
dd if="$disk" of="$prefix.ext4" bs=4M skip="$start" count="$size" \
  iflag=skip_bytes,count_bytes status=progress
config=$(debugfs -R 'cat /boot/extlinux/extlinux.conf' "$prefix.ext4")
if ! grep -qiE '^[[:space:]]*LINUX[[:space:]]+' <<< "$config"; then
  echo "Missing extlinux kernel entry in $prefix.ext4" >&2
  exit 1
fi
system=$(sed -nE 's/.*gnu\.system=(\/gnu\/store\/[^[:space:]]+).*/\1/p' <<< "$config" | head -n 1)
test -n "$system" || { echo "Missing Guix system path in extlinux" >&2; exit 1; }
database_dir=$(mktemp -d)
trap 'rm -r -- "$database_dir"' EXIT
graph_dir=/var/guix/sheng-reference-graphs
graph_entries=$(debugfs -R "ls -p $graph_dir" "$prefix.ext4")
graphs=()
while IFS= read -r name; do
  graph="$database_dir/graph-$name"
  debugfs -R "dump $graph_dir/$name $graph" "$prefix.ext4"
  test -s "$graph" || { echo "Missing Guix reference graph $name" >&2; exit 1; }
  graphs+=("$graph")
done < <(awk -F/ '$6 ~ /^[0-9]+$/ { print $6 }' <<< "$graph_entries")
(( ${#graphs[@]} > 0 )) || { echo "Missing Guix reference graphs" >&2; exit 1; }
mkdir -p "$database_dir/gnu" "$database_dir/var/guix/db"
ln -s /gnu/store "$database_dir/gnu/store"
"$GUIX" repl "$repo/scripts/register-image-closures.scm" "$database_dir" "${graphs[@]}"
database="$database_dir/var/guix/db/db.sqlite"
python3 - "$database" "$system" <<'PY'
import sqlite3
import sys
from pathlib import Path

database, system = sys.argv[1:]
with sqlite3.connect(Path(database).as_uri() + "?mode=ro", uri=True) as conn:
    if conn.execute("PRAGMA quick_check").fetchall() != [("ok",)]:
        sys.exit("The image store database failed SQLite quick_check")
    if not conn.execute("SELECT 1 FROM ValidPaths WHERE path = ?", (system,)).fetchone():
        sys.exit(f"The image store database has no registration for {system}")
    if conn.execute("PRAGMA foreign_key_check").fetchone():
        sys.exit("The image store database contains broken references")
print(f"Registered boot system: {system}")
PY
debugfs -w -R 'mkdir /var/guix/db' "$prefix.ext4"
debugfs -w -R "write $database /var/guix/db/db.sqlite" "$prefix.ext4"
debugfs -R "dump /var/guix/db/db.sqlite $database_dir/check.sqlite" "$prefix.ext4"
cmp "$database" "$database_dir/check.sqlite"
e2fsck -fn "$prefix.ext4"
if command -v img2simg >/dev/null; then
  img2simg "$prefix.ext4" "$prefix.sparse.img"
fi
ls -lh "$prefix".*
