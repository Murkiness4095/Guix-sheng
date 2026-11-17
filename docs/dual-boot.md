# 双系统安装与切换

参考 [NixOS-sheng 双系统指南](https://github.com/Murkiness4095/nixos-sheng/blob/2be57fe7da35b0b98963cc5da233ad6765d5c134/docs/dual-boot.md)。
ABL 通过 A/B 槽选择系统。Guix 的 U-Boot 从对应根分区读取 extlinux。

## 构建产物

| 项目 | Guix 使用 userdata | Guix 使用 linux |
| --- | --- | --- |
| 根分区 GPT 名称 | `userdata` | `linux` |
| GitHub Actions | `build-single` | `build-dual` |
| 开机镜像 | `sheng-boot.img` | `sheng-boot-dual.img` |
| TTY 根镜像 | `single-tty.sparse.img` | `dual-tty.sparse.img` |

在对应工作流选 `image=tty`，下载同一个 run 的两个文件。刷写前备份目标根分区、
启动槽和 DTBO，确认 sparse 镜像展开后能放进目标分区。以下命令在 ABL fastboot
执行，`fastboot devices` 应只列出目标平板。

## 保留 linux 上的 NixOS

以下布局已经验证 Guix 首启。NixOS 用 B 槽和 `linux`，其 EFI 文件位于独立
`sheng-esp`。Guix 用 A 槽和 `userdata`。如果 NixOS 当前在 A 槽，先按
实际布局调换命令里的 A/B 槽，根分区仍用 `userdata`。

以下操作清空 `userdata` 和 A 槽的旧 DTBO。确认 NixOS 的根和启动文件
均位于其他分区后执行。

```sh
fastboot erase dtbo_a &&
fastboot flash boot_a sheng-boot.img &&
fastboot erase userdata &&
fastboot flash userdata single-tty.sparse.img &&
fastboot set_active a &&
fastboot reboot
```

## 保留 A 槽的 Android

以下步骤适用于 Android A 槽已能启动，且已经有可覆盖的 `linux` 分区。
Guix 使用 B 槽。Guix 这套布局仍待实机验证。

```sh
fastboot erase dtbo_b &&
fastboot flash boot_b sheng-boot-dual.img &&
fastboot erase linux &&
fastboot flash linux dual-tty.sparse.img &&
fastboot set_active b &&
fastboot reboot
```

先擦目标根分区是为了清理 sparse 镜像跳过的旧数据。两套布局都应避开
`scripts/install-single.sh`，因为它会同时写两个启动槽。

## 切换系统与验收

进入 ABL fastboot 后，选择目标系统的槽，再重启。例如在第一套布局回到 NixOS：

```sh
fastboot set_active b
fastboot reboot
```

Guix 首启后按 [extlinux 验收](boot-chain.md#首启验收)确认登录、内核版本和根分区。
