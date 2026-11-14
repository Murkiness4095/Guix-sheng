#!/usr/bin/env python3
"""Android boot image v2 writer for the sheng ABL.

Emits the same bytes as AOSP mkbootimg.py with these arguments:
  --kernel u-boot-dtb.bin --dtb u-boot.dtb --pagesize 4096
  --base 0 --kernel_offset 0x8000 --tags_offset 0x1e00000
  --header_version 2 --cmdline ...

No ramdisk, second stage, or recovery dtbo; the header still records their
zeroed fields.  Guix's packaged mkbootimg is Android 7.1.2 and cannot write
header v2, which ABL rejects.
"""
import argparse
import hashlib
import struct

PAGE = 4096
HEADER_SIZE = 1660   # v2: v0 fields + recovery dtbo + header size + dtb
NAME_SIZE = 16
CMDLINE_SIZE = 512
EXTRA_CMDLINE_SIZE = 1024


def pad_to_page(out, size):
    out.write(b"\0" * ((PAGE - size % PAGE) % PAGE))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--kernel", required=True)
    p.add_argument("--dtb", required=True)
    p.add_argument("--cmdline", default="")
    p.add_argument("--base", type=lambda v: int(v, 0), default=0)
    p.add_argument("--kernel_offset", type=lambda v: int(v, 0), default=0x8000)
    p.add_argument("--tags_offset", type=lambda v: int(v, 0), default=0x1E00000)
    p.add_argument("--dtb_offset", type=lambda v: int(v, 0), default=0x1F00000)
    p.add_argument("--pagesize", type=int, default=PAGE)
    p.add_argument("--os_version", type=lambda v: int(v, 0), default=0)
    p.add_argument("--os_patch_level", type=lambda v: int(v, 0), default=0)
    p.add_argument("-o", "--output", required=True)
    args = p.parse_args()

    with open(args.kernel, "rb") as f:
        kernel = f.read()
    with open(args.dtb, "rb") as f:
        dtb = f.read()
    if not dtb:
        raise SystemExit("dtb must not be empty")

    cmdline = args.cmdline.encode()
    if len(cmdline) >= CMDLINE_SIZE:
        raise SystemExit(f"cmdline longer than {CMDLINE_SIZE - 1} bytes")

    header = bytearray(HEADER_SIZE)
    header[0:8] = b"ANDROID!"
    struct.pack_into("<I", header, 8, len(kernel))
    struct.pack_into("<I", header, 12, args.base + args.kernel_offset)
    # ramdisk size/address, second size/address: all zero.
    struct.pack_into("<I", header, 32, args.base + args.tags_offset)
    struct.pack_into("<I", header, 36, args.pagesize)
    struct.pack_into("<I", header, 40, 2)  # header_version
    struct.pack_into("<I", header, 44,
                     (args.os_version << 11) | args.os_patch_level)
    # name[16] at 48 stays zero.
    header[64:64 + len(cmdline)] = cmdline
    # sha1 over kernel, ramdisk, second, recovery dtbo and dtb, each followed
    # by its little-endian size; the empty stages contribute just a zero size.
    # AOSP pads the digest to 32 bytes with NULs.
    digest = hashlib.sha1(
        kernel + struct.pack("<I", len(kernel))
        + struct.pack("<I", 0) * 3
        + dtb + struct.pack("<I", len(dtb))
    ).digest()
    header[576:576 + len(digest)] = digest
    # extra_cmdline[1024] at 608 stays zero.
    struct.pack_into("<I", header, 1632, 0)        # recovery_dtbo_size
    struct.pack_into("<Q", header, 1636, 0)        # recovery_dtbo_offset
    struct.pack_into("<I", header, 1644, HEADER_SIZE)
    struct.pack_into("<I", header, 1648, len(dtb))
    struct.pack_into("<Q", header, 1652, args.base + args.dtb_offset)

    with open(args.output, "wb") as out:
        out.write(header)
        pad_to_page(out, len(header))
        out.write(kernel)
        pad_to_page(out, len(kernel))
        out.write(dtb)
        pad_to_page(out, len(dtb))


if __name__ == "__main__":
    main()
