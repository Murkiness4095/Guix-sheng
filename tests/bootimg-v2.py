#!/usr/bin/env python3
"""Check the boot.img v2 layout produced by packages/mkbootimg-v2.py.

The header offsets below are the contract ABL reads; a wrong offset or a
missing page pad produces an image that flashes and then does not boot.
"""
import hashlib
import os
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WRITER = os.path.join(ROOT, "packages", "mkbootimg-v2.py")


def main():
    kernel = bytes(range(256)) * 1200          # 307200 bytes
    dtb = b"dtb" * 4000 + b"\0"                # 12001 bytes
    cmdline = "console=ttyMSM0,115200n8 root=PARTLABEL=userdata"

    with tempfile.TemporaryDirectory() as tmp:
        kernel_path = os.path.join(tmp, "kernel")
        dtb_path = os.path.join(tmp, "dtb")
        out_path = os.path.join(tmp, "boot.img")
        with open(kernel_path, "wb") as f:
            f.write(kernel)
        with open(dtb_path, "wb") as f:
            f.write(dtb)
        subprocess.run(
            [sys.executable, WRITER, "--kernel", kernel_path, "--dtb", dtb_path,
             "--cmdline", cmdline, "-o", out_path],
            check=True)
        with open(out_path, "rb") as f:
            image = f.read()

    def u32(offset):
        return struct.unpack_from("<I", image, offset)[0]

    def u64(offset):
        return struct.unpack_from("<Q", image, offset)[0]

    assert image[:8] == b"ANDROID!"
    assert u32(8) == len(kernel)
    assert u32(12) == 0x8000                   # base + kernel_offset
    assert u32(16) == 0 and u32(20) == 0       # no ramdisk
    assert u32(24) == 0 and u32(28) == 0       # no second stage
    assert u32(32) == 0x1E00000                # base + tags_offset
    assert u32(36) == 4096
    assert u32(40) == 2                        # header version
    assert u32(44) == 0                        # os version

    encoded = cmdline.encode()
    assert image[64:64 + len(encoded)] == encoded
    assert image[64 + len(encoded):64 + 512] == b"\0" * (512 - len(encoded))
    assert image[48:64] == b"\0" * 16          # name

    expected_id = hashlib.sha1(
        kernel + struct.pack("<I", len(kernel))
        + b"\0" * 12
        + dtb + struct.pack("<I", len(dtb))).digest()
    assert image[576:596] == expected_id
    assert image[596:608] == b"\0" * 12
    assert image[608:1632] == b"\0" * 1024     # extra cmdline

    assert u32(1632) == 0                      # recovery_dtbo_size
    assert u64(1636) == 0                      # recovery_dtbo_offset
    assert u32(1644) == 1660                   # header_size
    assert u32(1648) == len(dtb)
    assert u64(1652) == 0x1F00000              # base + dtb_offset

    kernel_pages = (len(kernel) + 4095) // 4096
    dtb_pages = (len(dtb) + 4095) // 4096
    assert len(image) == 4096 * (1 + kernel_pages + dtb_pages)
    assert image[1660:4096] == b"\0" * (4096 - 1660)
    assert image[4096:4096 + len(kernel)] == kernel
    assert image[4096:4096 + kernel_pages * 4096].endswith(
        b"\0" * (kernel_pages * 4096 - len(kernel)))
    dtb_start = 4096 * (1 + kernel_pages)
    assert image[dtb_start:dtb_start + len(dtb)] == dtb
    assert image[dtb_start + len(dtb):] == b"\0" * (dtb_pages * 4096 - len(dtb))

    print("boot.img v2 layout ok")


if __name__ == "__main__":
    main()
