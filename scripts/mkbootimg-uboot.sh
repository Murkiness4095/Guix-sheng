#!/usr/bin/env bash
# Wrap U-Boot binaries in an Android boot.img for the sheng ABL.
# Usage: scripts/mkbootimg-uboot.sh <u-boot-output-dir> <root-partlabel> <out.img>
# Mirrors nixos-sheng packages/u-boot/default.nix.
set -euo pipefail
ubdir=$1
part=${2:-linux}
out=${3:-boot.img}
test -f "$ubdir/u-boot-dtb.bin" || { echo "missing $ubdir/u-boot-dtb.bin" >&2; exit 1; }
test -f "$ubdir/u-boot.dtb" || { echo "missing $ubdir/u-boot.dtb" >&2; exit 1; }
mkbootimg \
  --kernel "$ubdir/u-boot-dtb.bin" \
  --dtb "$ubdir/u-boot.dtb" \
  --cmdline "console=ttyMSM0,115200n8 console=ttyGS0,115200n8 g_serial.use_acm=1 root=PARTLABEL=$part" \
  --base 0x00000000 \
  --kernel_offset 0x00008000 \
  --tags_offset 0x01e00000 \
  --pagesize 4096 \
  --header_version 2 \
  --id \
  -o "$out"
ls -lh "$out"
