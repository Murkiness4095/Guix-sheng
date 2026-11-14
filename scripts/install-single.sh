#!/usr/bin/env bash
# Flash the single-system tty image: U-Boot to both boot slots, rootfs to
# userdata.  WIPES ANDROID.  Partition names are literals so no argument can
# redirect a write to xbl/abl.
#
# Usage: scripts/install-single.sh sheng-boot.img single-tty.sparse.img
set -euo pipefail
boot=${1:?usage: $0 <boot.img> <rootfs.sparse.img|rootfs.ext4>}
root=${2:?usage: $0 <boot.img> <rootfs.sparse.img|rootfs.ext4>}

die() { echo "$*" >&2; exit 1; }

[ -f "$boot" ] || die "no boot image at $boot"
[ "$(head -c 8 "$boot")" = "ANDROID!" ] || die "$boot is not an Android boot image"
[ -f "$root" ] || die "no rootfs at $root"

sparse=$(od -An -tx1 -N4 -j0 "$root" | tr -d ' \n')
ext4=$(od -An -tx1 -N2 -j1080 "$root" | tr -d ' \n')
if [ "$sparse" = "3aff26ed" ]; then
  kind="Android sparse"
elif [ "$ext4" = "53ef" ]; then
  kind="raw ext4"
else
  die "$root is neither an Android sparse nor a raw ext4 image"
fi

n=$(fastboot devices | grep -c fastboot || true)
[ "$n" != 0 ] || die "no device in fastboot: hold POWER ~15s, then VOLUME DOWN and plug USB"
[ "$n" = 1 ] || die "$n devices in fastboot -- refusing to guess"

echo "boot:   $(basename "$boot")"
echo "rootfs: $(basename "$root") ($kind)"
echo "*** THIS ERASES USERDATA (ANDROID) ***"
read -r -p "type 'wipe' to continue: " reply
[ "$reply" = wipe ] || die aborted

fastboot flash boot_a "$boot"
fastboot flash boot_b "$boot"
# Sparse DONT_CARE chunks leave old bytes in place; erase first so ext4's
# uninitialised block groups read zeros.
fastboot erase userdata
fastboot flash userdata "$root"
echo "done. check 'fastboot devices' still shows the device, then: fastboot reboot"
