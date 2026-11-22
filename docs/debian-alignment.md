# 与 debian-sheng 的功能对齐

第一参考是 [NixOS-sheng](https://github.com/Murkiness4095/nixos-sheng) 的
`2be57fe7da35b0b98963cc5da233ad6765d5c134`。
[debian-sheng](https://github.com/ianchb/debian-sheng) 的 `a93aaa1`
用于补缺和交叉核对。系统集成按 Guix 和 Shepherd 接口实现。

专有设备移植：固件 blob、非自由内核配置、专有用户态组件按 debian-sheng 的
清单直接使用，不以 Guix 的自由软件默认值为准。

## 基准来源

| 项 | debian-sheng | 本仓库 |
| --- | --- | --- |
| 内核 | 默认使用 `ianchb/sm8550-mainline` 的预编译 release | 按 NixOS-sheng `2be57fe` 从 `87ac0f2` 编译，复用 Debian 全量配置及 NixOS 配置片段和源码修改 |
| 内核 ARM64 头文件生成 | NixOS 构建环境能访问 `/bin/sh` | Guix 沙箱改用 Kbuild 的 `$(CONFIG_SHELL)`（CI #44020864761） |
| 固件 | `ianchb/sheng-firmware` | 同源，`packages/firmware.scm` 固定提交 |
| boot.img | `mkbootimg`（header v2） | `packages/mkbootimg-v2.py`，输出与 AOSP 逐字节一致 |
| UCM / 传感器 / 充电 / 指纹 / 笔 | 各 DEBIAN 包 + systemd 单元 | `packages/peripherals.scm` 对应原 NixOS 配方；独立 CI 验证，Shepherd 接线待完成 |
| 指纹构建 | 上游脚本构建 QTEE 后端与 libfprint | Guix 构建 libfprint 时临时将后端目录加入动态库搜索路径（CI #44061201439）；在已安装的 QTEE listener 中加入 Guix glibc RUNPATH（CI #44064086877） |
| 根文件系统 | Debian rootfs + systemd | Guix 镜像 + shepherd |
| 刷机 | `boot.img` + `rootfs.img` 到 `boot`/`userdata` 或 `linux` | `scripts/install-single.sh` / 双系统待做 |

## 已对齐

- 内核上游仓库。
- 固件仓库与提交。
- boot.img header v2 的字段与 AOSP/ debian 的 `mkbootimg` 一致。
- 单系统根分区 `userdata`，双系统根分区 `linux`。

## 已知差异（需逐项消掉）

| 差异 | 原因 | 处理 |
| --- | --- | --- |
| U-Boot defconfig | Debian 直启没有此步骤；NixOS 用 `buildUBoot` | 固定的 U-Boot 提交 `7025b79` 中 `CONFIG_CLK_QCOM_SM8550=y` 重复两次，Guix 构建拒绝重复项（CI #43688501887）；源补丁删除一条，保留同一取值；配置阶段直接调用 make sm8550_defconfig，对齐 NixOS，避开 Guix 额外的一致性检查（CI #43945937332） |
| U-Boot 菜单 | 默认入口显示 Boot NixOS | Guix 使用 Boot Guix 标签，extlinux 命令保持同一入口 |
| 启动方式 | 内核 `Image.gz` + 追加 dtb 的 boot.img，ABL 直接启动，无 initrd；cmdline 仅 `root=PARTLABEL=` | U-Boot → extlinux，内核 `Image` + 独立 `FDT` + Guix initrd | 首个 TTY 沿用 NixOS 的 U-Boot 路线；Debian 直启保留为参考 |
| 根文件系统初始化 | Debian `/sbin/init` | Guix initrd + `gnu.system=` | 镜像构建注册 store 闭包并关闭 WAL，构建后检查 SQLite；旧镜像需单独处理 |
| 用户态服务：systemd 单元 | Guix 用 shepherd | 按 `services/` 逐项等价实现 |
| 桌面：debian 可选 GNOME/KDE/server | Guix 提供 tty/kde/gnome/niri/noctalia | 保留现有变体，功能对齐 debian 的 server/GNOME/KDE |

## 记录规则

- 新增或消除差异时更新本表，并在 `TODO.md` 保留对应待办。
- 参考的 debian-sheng 版本变化时，重新核对内核分支、配置和固件提交。

## 外设服务接线

`sheng-os` 可用 `#:vendor-services? #t` 接入首批外设配置。当前包括
合并板级和通用 UCM2 配置后的 `ALSA_CONFIG_UCM2`，以及等待触控驱动
节点后启动 THP 的 Shepherd 服务，以及 FastRPC 的可写 SSC 注册表、
传感器代理及其 udev、D-Bus、Polkit 接线。参考 NixOS-sheng 的
`modules/audio.nix`、`modules/firmware.nix` 和 THP systemd 单元。
默认 TTY 首启镜像仍可单独验证。WirePlumber、HiFi 启动应用、
指纹、充电和其余设备服务待接线，实机触控和音频待验证。

根分区扩容参照 NixOS-sheng `2be57fe` 的 `modules/hardware.nix` 中
`fileSystems."/".autoResize`。Guix 由 Shepherd 在根分区挂载和 udev 就绪后
运行 `resize2fs`。只有当前可写的 ext4 根挂载与工作流对应的
`userdata` 或 `linux` 指向同一设备时才扩容。每次启动均可安全重试。

`libssc` 仍固定到 NixOS-sheng 使用的 `033e2a32095c024d6dbdfb1d4ae1db4a94be32f1`。
由于 GitHub runner 多次从 Codeberg 下载返回 504（如 #44161062321），
仓库保存原始归档，SHA-256 为
`80eb911009fccea52ab0ea0dcc78572a00757abd840e8dc81e9b72cd230526b8`。
QMI 重试补丁在解包后应用。

## 键盘盖认证

参考 NixOS-sheng `2be57fe7da35b0b98963cc5da233ad6765d5c134` 的固件模块。所有 Guix 镜像默认由 Shepherd 启动 QTEE 安全文件系统配置、QTEE 监听器和 `xiaomi_devauth`。认证程序沿用固定源码与 `devauth.mbn`，通过 `/dev/nanosic_auth` 与驱动通信。QTEE 运行时仍来自现有 sheng-fingerprint 软件包。待验证实机认证和键盘空闲后输入。

## NixOS 板级服务核对

Niri 会话显式 include 外设启动配置，在启用 `vendor_services` 时启动手写笔状态托盘和键盘麦克风静音辅助程序。此前仅安装 XDG autostart 条目，当前 niri 启动接线没有运行这些条目。此修复待 CI 和实机验证，参考版本仍为 `2be57fe`。

| 功能 | 当前 Guix 状态 |
| --- | --- |
| 键盘盖 | 认证接线在 `codex/keyboard-auth` 验证中。折叠角度策略接入 `vendor_services`。麦克风静音灯同步和背光权限规则还未接线。 |
| 音频 | 板级 UCM 需启用 `vendor_services`。WirePlumber 板级规则和开机 HiFi verb 尚未接入。 |
| 触控、触控笔、传感器 | THP、FastRPC 和传感器代理需启用 `vendor_services`。桌面镜像启用同一选项时启动触控笔状态托盘。 |
| 指纹和充电 | MIPPS 充电认证规则接入 `vendor_services`。fprintd 后端和固件路径、充电模式服务尚未接到系统。 |
| 摄像头 | 尚未接入 libcamera/WirePlumber 摄像头发现及 Qt GStreamer 环境。 |
| 桌面与存储 | 已接入内部 UFS 维护分区隐藏规则。KDE 登录界面的屏幕键盘尚未接入。 |
| 双系统与更新 | extlinux 和根分区扩容已接线。启动槽成功标记仍是骨架。旧 CI 镜像的 store 数据库注册阻碍现有世代的可靠滚动更新。EFI 在单独分支。 |

外设扩展继续参考 NixOS-sheng `2be57fe`。`vendor_services` 启用 HiFi UCM 初始化、WirePlumber 音频规则、键盘灯权限和按内核参数启动的充电界面。桌面同时启用键盘静音灯辅助程序、摄像头配置和板级 fprintd 服务。接线待 CI 构建和实机验收。

Niri 的自动登录与 greeter 入口统一通过 `dbus-run-session` 启动；启动程序等待 PipeWire socket 后启动 Pulse 兼容服务和 WirePlumber，再启动 noctalia 与可选外设程序。实机确认原镜像没有用户 D-Bus 和音频进程。Zed 包显式提供 Mesa Freedreno ICD，实机指定该驱动后创建窗口成功。上述改动待新 CI 镜像和重启验收。

桌面镜像增加微软官方 ARM64 VS Code 1.147.0，固定发布提交 `8a14f0cc1b08d531eb83255ea3764ae22aa932b5` 与 SHA-256 `b137f53a29a1debf9fc30027823556863202f94c10d924dd70f2d2370795412d`。通过原生 Wayland 启动并启用 Wayland IME。Zed 的 Wayland 触屏支持由上游 issue #13698 跟踪，当前未将 Zed 宣称为已通过触屏验收。

## 2026-11-22 对齐复核

基准仍为 NixOS-sheng `2be57fe7da35b0b98963cc5da233ad6765d5c134`。

- MiPPS 原规则使用 `SYSTEMD_WANTS`，`--usb-online-trigger` 也调用 systemctl。Guix 改由 udev 写入请求文件、Shepherd 监视请求并通过 flock 调用固定版本认证程序。尚待原装充电器下确认协商结果和实际功率。
- Niri 根镜像纳入个人 niri 配置的 120Hz、快捷键、Fcitx5 启动及 Noctalia 默认配置、壁纸、logo。用户已有 Noctalia 配置保留。xwayland-satellite 加入会话 PATH，由 niri 管理。个人配置中的外接显示器条目一并保留，匹配设备连接时生效。
- 个人配置的 niri 辅助包纳入 niri 镜像。KDE/GNOME 使用自己的桌面配置；中文字体与编辑器供所有桌面镜像使用。
- 未对齐：`modules/boot-slot.scm` 仍为空实现，没有 NixOS 的 qbootctl 成功标记。SDDM 虚拟键盘接线仍缺少 NixOS 的 kwin input-method 配置。可选 tmpfs-root/preservation 与 Nix bootstrap 属于不同系统机制，未移植。
- 相机 Guix 的 GStreamer plugin union 缺少 NixOS 使用的 libcamera 项，补入。实际相机画面、指纹识别、传感器旋转、充电功率、长期休眠和键盘稳定性仍未完成验收。
- “已打包”“已接线”“实机功能通过”分别记录，当前不能宣称完全对齐。
