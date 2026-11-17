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
e2fsck -fn "$prefix.ext4"
config=$(debugfs -R 'cat /boot/extlinux/extlinux.conf' "$prefix.ext4")
if ! grep -qiE '^[[:space:]]*LINUX[[:space:]]+' <<< "$config"; then
  echo "Missing extlinux kernel entry in $prefix.ext4" >&2
  exit 1
fi
if command -v img2simg >/dev/null; then
  img2simg "$prefix.ext4" "$prefix.sparse.img"
fi
ls -lh "$prefix".*
