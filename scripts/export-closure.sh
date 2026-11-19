#!/usr/bin/env bash
# Export the boot system of a built sheng image as a signed Guix nar bundle.
# Usage: scripts/export-closure.sh <system-path|image.ext4> [output.nar.zst]
#
# The archive is signed by the local guix-daemon key, so importing it on the
# tablet requires that public key in /etc/guix/acl (guix archive --authorize).
# The store path is printed on stdout.
set -euo pipefail
GUIX=${GUIX:-guix}
if (( $# < 1 )); then
  echo "usage: $0 <system-path|image.ext4> [output.nar.zst]" >&2
  exit 2
fi
src=$1
out=${2:-sheng-closure.nar.zst}
system=

if [[ $src == /gnu/store/* ]]; then
  system=$src
else
  config=$(debugfs -R 'cat /boot/extlinux/extlinux.conf' "$src" 2>/dev/null)
  system=$(sed -nE 's/.*gnu\.system=(\/gnu\/store\/[^[:space:]]+).*/\1/p' \
             <<< "$config" | head -n 1)
fi
if [[ $system != /gnu/store/*-system || ! -d $system ]]; then
  echo "no boot system in $src" >&2
  exit 1
fi

mkdir -p "$(dirname "$out")"
"$GUIX" archive --export -r "$system" | zstd -T0 -o "$out"
printf '%s\n' "$system"
