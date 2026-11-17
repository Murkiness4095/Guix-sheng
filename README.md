# Guix-sheng

适用于小米平板 6S Pro 12.4（sheng）的 GNU Guix System 移植。
板级实现以 [NixOS-sheng](https://github.com/Murkiness4095/nixos-sheng)
为参考，使用 sheng 内核、设备树和固件。

## 选安装布局

| 场景 | CI 工作流 | Guix 根分区 | 启动方式 |
| --- | --- | --- | --- |
| Guix 使用整个或已缩小的 `userdata` | `build-single` | `userdata` | U-Boot → extlinux |
| 保留 `userdata` 上的 Android 或 NixOS | `build-dual` | `linux` | 独立 ABL 槽 → U-Boot → extlinux |
| 已准备独立 `sheng-esp` | `Guix EFI bundle` | 按布局选 `userdata` 或 `linux` | U-Boot EFI → GRUB EFI |

已有 `userdata` 和 `linux` 两个分区、希望保留 NixOS 的设备，从
[双系统安装指南](docs/dual-boot.md)开始。

## 构建并下载

1. 在 GitHub Actions 打开对应工作流，再选择 `boot-chain` 分支。
2. 用 `image` 选择 `tty`、`niri`、`kde` 或 `gnome`。首次启动验证用
   `tty`。选 `none` 只构建开机镜像。四种根镜像均包含 `fastfetch`。
3. `desktop_username` 和 `desktop_password` 默认都是 `sheng`，对本次
   根镜像的登录生效，包括 TTY。下载同一个 run 的开机镜像和 sparse 根镜像。
   `auto_login` 默认开启。TTY 会直接进入 tty1 的用户 shell，桌面会启动对应会话。
   取消勾选可恢复登录界面，已有系统可在 `sheng-os` 调用中设置 `#:auto-login? #f`。

| 工作流 | 开机镜像 | 根镜像示例 |
| --- | --- | --- |
| `build-single` | `sheng-boot.img` | `single-tty.sparse.img` |
| `build-dual` | `sheng-boot-dual.img` | `dual-tty.sparse.img` |

当前已经构建并下载过 [单系统 U-Boot 开机镜像](https://github.com/Murkiness4095/Guix-sheng/actions/runs/43949538335)。
[TTY 完整构建曾在内核阶段失败](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44013162160)，
实机登录尚无验收记录。以对应运行的日志和产物为准。

## 文档

- [单系统首启与 extlinux 验收](docs/boot-chain.md)
- [双系统安装与 NixOS 共存](docs/dual-boot.md)
- [可选 GRUB EFI 安装套件](docs/efi-install.md)
- [最小 Guix 系统声明](examples/minimal/README.md)
- [CI、固定频道与缓存](docs/CI.md)
- [维护交接](docs/HANDOVER.md)与[上游实现差异](docs/debian-alignment.md)

许可证为 MIT。
