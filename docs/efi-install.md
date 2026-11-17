# 可选 GRUB EFI 安装套件

Guix EFI 采用 ABL → U-Boot EFI → GRUB EFI → Guix 内核和 initrd。
U-Boot 从内置 ESP 读取 ARM64 GRUB 和 sheng DTB。GRUB 按
`Guix_image` 卷标找到 Guix 生成的 `/boot/grub/grub.cfg`。

## 布局和产物

| CI `layout` | 根分区 GPT 名称 | 压缩根镜像 |
| --- | --- | --- |
| `single` | `userdata` | `userdata.sparse.img.zst` |
| `dual` | `linux` | `linux.sparse.img.zst` |

两个布局都要求独立 GPT ESP `sheng-esp`。套件包含
`sheng-boot-efi.img`、`sheng-esp.sparse.img`（512 MiB、FAT32、
4096 字节逻辑扇区）、对应根镜像和 `SHA256SUMS`。
使用同一个套件的全部文件。

## 构建与验证

`Guix EFI bundle` 首轮在 `boot-chain` 上通过推送触发，选择
`dual`。工作流进入默认分支后，可在 Actions 用 `layout` 手动选
`single` 或 `dual`。目前[首轮 CI](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44016355246)
尚无实机验收记录。

套件用于全新部署，会覆盖目标根分区和 ESP。已有 NixOS 的 EFI 文件
应保留在其现有存储位置。若设备只有 `userdata` 和 `linux`，
可先按[双系统指南](dual-boot.md)走 extlinux，无需调整 GPT。
