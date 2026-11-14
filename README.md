# Guix-sheng

Xiaomi Pad 6S Pro（sheng）的 GNU Guix（aarch64）移植。设备支持参考
[nixos-sheng](https://github.com/Murkiness4095/nixos-sheng) 与
[debian-sheng](https://github.com/ianchb/debian-sheng)。

## 布局

| 路径 | 内容 |
| --- | --- |
| `channels.scm` | Guix 频道（guix master + midnight） |
| `images/` | 镜像声明：单/双系统 × tty/kde/gnome/niri/noctalia |
| `images/base.scm` | 共享 OS 生成器（greetd + noctalia greeter + librewolf） |
| `packages/` | 内核、U-Boot、固件、用户态包 |
| `modules/` `services/` | Guix 模块与 shepherd 服务 |
| `scripts/build-image.sh` | 构建并提取 ext4 根分区 |
| `examples/` | 最小/桌面/双系统/多机/tmpfs 样板 |
| `docs/` `tests/` | 文档与测试 |

## 镜像

单系统与双系统分别由两条工作流构建：

- `build-single`：`single-tty` `single-kde` `single-gnome` `single-niri` `single-noctalia`
- `build-dual`：`dual-tty` `dual-kde` `dual-gnome` `dual-niri` `dual-noctalia`

所有桌面镜像统一使用 **noctalia greeter** 登录，浏览器统一为 **librewolf**。
双系统镜像根分区标签为 `linux`（Android A / Guix B）。

构建时可自定义桌面用户名/密码（`workflow_dispatch` 输入）：

- `desktop_username`，默认 `sheng`
- `desktop_password`，默认 `sheng`

CI 将输入写入 `images/settings.scm`（不提交）后构建。

## 快速开始

已通过 CI 的路径（单系统 tty，镜像本体）：

```sh
guix system image -L . images/single-tty.scm
```

`-L .` 让镜像文件能加载本仓库的 `(packages ...)` 与 `(modules ...)`。

本地只有官方 guix 频道时，niri/noctalia 变体需要先：

```sh
guix pull -C channels.scm
```

## 验证状态

| 项目 | 状态 |
| --- | --- |
| 十种镜像求值 | ✅ 本地 `guix repl` 全部通过 |
| `single-tty` 镜像构建 | ✅ CI 通过（旧骨架，未含 sheng 内核） |
| 启动链（U-Boot → extlinux → tty） | 已实现，待 CI 构建与实机首启，见 `docs/boot-chain.md` |
| 内核/U-Boot/固件包 | 真实包已接入；源哈希已核对；未构建 |
| 桌面/双系统变体 | 求值通过；实机未验证 |
| 实机刷入与启动 | 未验证 |

`guix system image` 在镜像内注册 store DB 时会遇到 SQLite `database is locked`；
`images/*.scm` 已通过 `#:register-closures? #f` 跳过该步骤（闭包仍复制，镜像可启动）。

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
