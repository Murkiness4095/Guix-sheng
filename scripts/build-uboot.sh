#!/usr/bin/env bash
# Build the Android boot image ABL loads: U-Boot + mkbootimg wrapper.
# Usage: scripts/build-uboot.sh [single|dual]
# Produces sheng-boot.img or sheng-boot-dual.img in the current directory.
set -euo pipefail
GUIX=${GUIX:-guix}
repo=$(cd "$(dirname "$0")/.." && pwd)
mode=${1:-single}
case "$mode" in
  single) package=u-boot-sheng; out=sheng-boot.img ;;
  dual)   package=u-boot-sheng-dual; out=sheng-boot-dual.img ;;
  *) echo "usage: $0 [single|dual]" >&2; exit 1 ;;
esac
store=$("$GUIX" build -L "$repo" -e "(@ (packages u-boot) $package)")
test -f "$store/boot.img" || { echo "no boot.img in $store" >&2; exit 1; }
cp "$store/boot.img" "$out"
echo "$out: $(sha256sum "$out" | cut -d' ' -f1)"
