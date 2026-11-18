# Guix-sheng

适用于小米平板 6S Pro 12.4（sheng）的 GNU Guix System 移植。
板级实现以 [NixOS-sheng](https://github.com/Murkiness4095/nixos-sheng)
为参考，使用 sheng 内核、设备树和固件。

## 选安装布局

| 场景 | CI 工作流 | Guix 根分区 | 启动方式 |
| --- | --- | --- | --- |
| Guix 使用整个或已缩小的 `userdata` | `build-single` | `userdata` | U-Boot → extlinux |
| 保留 `userdata` 上的 Android 或 NixOS | `build-dual` | `linux` | 独立 ABL 槽 → U-Boot → extlinux |
| 保留 `linux` 上的 NixOS | `build-single` | `userdata` | 独立 ABL 槽 → U-Boot → extlinux |

保留现有系统时，先按它占用的根分区选择 Guix 产物，再按 A/B 槽刷写。
见[双系统安装与切换](docs/dual-boot.md)。

## 构建并下载

1. 在 GitHub Actions 打开对应工作流，再选择 `boot-chain` 分支。
2. 用 `image` 选择 `tty`、`niri`、`kde` 或 `gnome`。首次启动验证用
   `tty`。选 `none` 只构建开机镜像。四种根镜像均包含 `fastfetch`（Guix 的 `fastfetch-minimal` 包）。
   默认主机名为 `guix`，登录账号仍由构建输入决定。
   所有镜像预装 Fish、Starship 和 Git，登录账号默认使用 Fish。桌面镜像预装 Kitty 和 Zed，niri 镜像额外预装 Fuzzel。
   桌面镜像还预装 Fcitx 5、中文拼音、配置工具及 GTK 和 Qt 输入模块。
3. `desktop_username` 和 `desktop_password` 默认都是 `sheng`，对本次
   根镜像的登录生效，包括 TTY。下载同一个 run 的开机镜像和 sparse 根镜像。
   `auto_login` 默认开启。TTY 会直接进入 tty1 的用户 shell，桌面会启动对应会话。
   取消勾选可恢复登录界面，已有系统可在 `sheng-os` 调用中设置 `#:auto-login? #f`。

| 工作流 | 开机镜像 | 根镜像示例 |
| --- | --- | --- |
| `build-single` | `sheng-boot.img` | `single-tty.sparse.img` |
| `build-dual` | `sheng-boot-dual.img` | `dual-tty.sparse.img` |

[单系统 TTY 修正版](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44065603032)
已在实机从 `userdata` 启动并自动登录到 TTY。
手动构建可选 `vendor_services`，接入试验性的板级 UCM、触控和传感器服务。

## 文档
个人系统配置可通过 Guix channel 导入 `(sheng system)`。见[最小样板](examples/minimal/README.md)。
Guix EFI 实验保留在 [codex/efi](https://github.com/Murkiness4095/Guix-sheng/tree/codex/efi)。

- [单系统首启与 extlinux 验收](docs/boot-chain.md)
- [双系统安装与 NixOS 共存](docs/dual-boot.md)
- [最小 Guix 系统声明](examples/minimal/README.md)
- [CI、固定频道与缓存](docs/CI.md)
- [维护交接](docs/HANDOVER.md)与[上游实现差异](docs/debian-alignment.md)

许可证为 MIT。
