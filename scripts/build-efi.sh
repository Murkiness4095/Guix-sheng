#!/usr/bin/env bash
# Build the optional Guix GRUB EFI bundle on an ARM CI runner.
set -euo pipefail
case "${1:-}" in
  single) root=userdata ;;
  dual) root=linux ;;
  *) echo "usage: $0 single|dual" >&2; exit 1 ;;
esac
export SHENG_EFI_LAYOUT=$1
repo=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo"
disk=$("${GUIX:-guix}" system image -L . images/efi-tty.scm)
mkdir -p efi-bundle
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
sfdisk --json "$disk" | python3 -c '
import json, sys
table = json.load(sys.stdin)["partitiontable"]
esp, root = table["partitions"]
for part in (esp, root):
    print(part["start"] * table["sectorsize"], part["size"] * table["sectorsize"])
' > "$scratch/offsets"
{
  read -r esp_start esp_size
  read -r root_start root_size
} < "$scratch/offsets"
dd if="$disk" of="$scratch/esp.img" bs=4M skip="$esp_start" count="$esp_size" iflag=skip_bytes,count_bytes
dd if="$disk" of="$scratch/root.ext4" bs=4M skip="$root_start" count="$root_size" iflag=skip_bytes,count_bytes
mkdir "$scratch/esp"
mcopy -i "$scratch/esp.img" -s '::*' "$scratch/esp/"
test -s "$scratch/esp/EFI/BOOT/BOOTAA64.EFI"
test -s "$scratch/esp/sheng.dtb"
truncate -s "$esp_size" "$scratch/esp-4k.img"
mkfs.fat -F 32 -S 4096 -n SHENG-ESP "$scratch/esp-4k.img"
mcopy -i "$scratch/esp-4k.img" -s "$scratch/esp/"* ::
img2simg "$scratch/esp-4k.img" efi-bundle/sheng-esp.sparse.img 4096
img2simg "$scratch/root.ext4" "$scratch/root.sparse.img" 4096
zstd -T0 "$scratch/root.sparse.img" -o "efi-bundle/$root.sparse.img.zst"
scripts/build-uboot.sh "efi-$SHENG_EFI_LAYOUT"
mv sheng-boot-efi.img efi-bundle/
printf 'layout=%s\nroot_partlabel=%s\nesp_partlabel=sheng-esp\nrevision=%s\n' \
  "$SHENG_EFI_LAYOUT" "$root" "$(git rev-parse HEAD)" > efi-bundle/manifest.txt
(cd efi-bundle && sha256sum *.img *.zst manifest.txt > SHA256SUMS)
