# Guix-sheng

Xiaomi Pad 6S Pro（sheng）的 GNU Guix（aarch64）移植。设备支持参考
[nixos-sheng](https://github.com/Murkiness4095/nixos-sheng) 与
[debian-sheng](https://github.com/ianchb/debian-sheng)。

## 布局

| 路径 | 内容 |
| --- | --- |
| `channels.scm` | Guix 频道（guix master + midnight） |
| `images/` | 镜像声明：单/双系统 × tty/kde/gnome/niri/noctalia |
| `images/base.scm` | 共享 OS 生成器（按桌面选择 SDDM/GDM/noctalia greeter） |
| `packages/` | 内核、U-Boot、固件、用户态包 |
| `modules/` `services/` | Guix 模块与 shepherd 服务 |
| `scripts/build-image.sh` | 构建并提取 ext4 根分区 |
| `examples/` | 最小/桌面/双系统/多机/tmpfs 样板 |
| `docs/` `tests/` | 文档与测试 |

## 镜像

单系统与双系统分别由两条工作流构建：

- `build-single`：`single-tty` `single-kde` `single-gnome` `single-niri` `single-noctalia`
- `build-dual`：`dual-tty` `dual-kde` `dual-gnome` `dual-niri` `dual-noctalia`

KDE 使用 **SDDM**，GNOME 使用 **GDM**，niri/noctalia 使用 **noctalia greeter**，
tty 镜像保留文本 getty。浏览器统一为 **librewolf**。
双系统镜像根分区标签为 `linux`（Android A / Guix B）。

构建时可自定义桌面用户名/密码（`workflow_dispatch` 输入）：

- `desktop_username`，默认 `sheng`
- `desktop_password`，默认 `sheng`

CI 将输入写入 `images/settings.scm`（不提交）后构建。

## 构建与进度

首个板级 TTY 尚无已验证的可刷产物。构建走 GitHub Actions 的 `build-single`，
将 `variants` 设为 `single-tty`。当前阻塞、产物状态和 CI 记录见
[维护交接](docs/HANDOVER.md)，实机检查见[启动链](docs/boot-chain.md)。
仓库工作规则见 [AGENTS.md](AGENTS.md)。

## 上游来源

| 组件 | 来源 | 版本/提交 |
| --- | --- | --- |
| 内核 | https://github.com/code002-2/sm8550-mainline | 默认分支 `sheng-7.2-rc7`，提交 `52a5197235edd2a2b6559d69b45557cf83f7d111` |
| 内核配置 | debian-sheng `sm8550.config` | 提交 `a93aaa1`，存于 `packages/kernel/sm8550.config`；clang/`LLVM=1` 构建 |
| U-Boot | https://github.com/SushyDev/u-boot | `xiaomi-sheng`，提交 `7025b792e2884c5fb4747d891e30002ea029048a` |
| U-Boot 补丁 | nixos-sheng `packages/u-boot/patches/` | 见目录 |
| 固件 | https://github.com/ianchb/sheng-firmware | 提交 `053da477a5c338ac28d7c1c869e8c3ff7ca24d11` |
| 启动配置 | `modules/sheng-bootloader.scm`（extlinux.conf 生成器） | 本仓库 |
| boot.img 打包 | `packages/mkbootimg-v2.py`（header v2；与 AOSP 输出逐字节一致） | 本仓库 |
| niri | Guix 官方 `(gnu packages window-management)` | 随频道提交 |
| noctalia / greeter | https://codeberg.org/stampede/midnight | `main` |

## 许可证

MIT。
