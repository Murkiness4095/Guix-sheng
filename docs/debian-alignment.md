# 与 debian-sheng 的功能对齐

第一参考：[ianchb/debian-sheng](https://github.com/ianchb/debian-sheng)
（`master`，提交 `a93aaa1`）。debian-sheng 已有的做法、版本和文件优先照搬；
只有它没有的（Guix 系统集成、shepherd 服务、extlinux 生成）才在本仓库实现。

专有设备移植：固件 blob、非自由内核配置、专有用户态组件按 debian-sheng 的
清单直接使用，不以 Guix 的自由软件默认值为准。

## 基准来源

| 项 | debian-sheng | 本仓库 |
| --- | --- | --- |
| 内核 | 默认使用 `ianchb/sm8550-mainline` 的预编译 release | 使用 `7.3.4` 的 `linux-xiaomi-sheng.deb`，固定 SHA-256。内核、DTB、模块一起解包并按 Guix 布局安装 |
| 固件 | `ianchb/sheng-firmware` | 同源，`packages/firmware.scm` 固定提交 |
| boot.img | `mkbootimg`（header v2） | `packages/mkbootimg-v2.py`，输出与 AOSP 逐字节一致 |
| UCM / 传感器 / 充电 / 指纹 / 笔 | 各 DEBIAN 包 + systemd 单元 | `packages/firmware/`、`services/` 逐项移植 |
| 根文件系统 | Debian rootfs + systemd | Guix 镜像 + shepherd |
| 刷机 | `boot.img` + `rootfs.img` 到 `boot`/`userdata` 或 `linux` | `scripts/install-single.sh` / 双系统待做 |

## 已对齐

- 预编译内核来源。
- 固件仓库与提交。
- boot.img header v2 的字段与 AOSP/ debian 的 `mkbootimg` 一致。
- 单系统根分区 `userdata`，双系统根分区 `linux`。

## 已知差异（需逐项消掉）

| 差异 | 原因 | 处理 |
| --- | --- | --- |
| U-Boot defconfig | Debian 直启没有此步骤；NixOS 用 `buildUBoot` | 固定的 U-Boot 提交 `7025b79` 中 `CONFIG_CLK_QCOM_SM8550=y` 重复两次，Guix 构建拒绝重复项（CI #43688501887）；源补丁删除一条，保留同一取值 |
| 启动方式 | 内核 `Image.gz` + 追加 dtb 的 boot.img，ABL 直接启动，无 initrd；cmdline 仅 `root=PARTLABEL=` | U-Boot → extlinux，内核 `Image` + 独立 `FDT` + Guix initrd | 首个 TTY 沿用 NixOS 的 U-Boot 路线；Debian 直启保留为参考 |
| 根文件系统初始化 | Debian `/sbin/init` | Guix initrd + `gnu.system=` | 暂不取消 initrd；`#:register-closures? #f` 的 store DB 问题首启后处理 |
| 用户态服务：systemd 单元 | Guix 用 shepherd | 按 `services/` 逐项等价实现 |
| 桌面：debian 可选 GNOME/KDE/server | Guix 提供 tty/kde/gnome/niri/noctalia | 保留现有变体，功能对齐 debian 的 server/GNOME/KDE |

## 记录规则

- 新增或消除差异时更新本表，并在 `TODO.md` 保留对应待办。
- 参考的 debian-sheng 版本变化时，重新核对内核分支、配置和固件提交。
