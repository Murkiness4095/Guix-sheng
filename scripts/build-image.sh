#!/usr/bin/env bash
# Build a sheng disk image and extract the raw ext4 root partition.
# Usage: scripts/build-image.sh images/single-tty.scm [out-prefix]
set -euo pipefail
GUIX=${GUIX:-guix}
src=$1
prefix=${2:-$(basename "$src" .scm)}
disk=$("$GUIX" system image "$src" 2>/dev/null | tail -1)
test -f "$disk" || { echo "no disk image from guix: $disk" >&2; exit 1; }
echo "disk image: $disk"
# root partition starts at root-offset = 512 * 2048 = 1 MiB (gnu/system/image.scm)
dd if="$disk" of="$prefix.ext4" bs=1M skip=1 status=progress
e2fsck -fy "$prefix.ext4" >/dev/null 2>&1 || true
if command -v img2simg >/dev/null; then
  img2simg "$prefix.ext4" "$prefix.sparse.img"
fi
ls -lh "$prefix".*
