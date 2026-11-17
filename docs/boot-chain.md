# extlinux 安装与首启

ABL 加载 Android header v2 格式的 `boot.img`，其中包含板级 U-Boot。
U-Boot 按 GPT 分区名查找根分区，通过
`/boot/extlinux/extlinux.conf` 加载 Guix store 中的内核、initrd 和
`lib/dtbs/qcom/sm8550-xiaomi-sheng.dtb`。

## 单系统安装

`build-single` 的 `image=tty` 需要同时产出 `sheng-boot.img` 与
`single-tty.sparse.img`。开机镜像和根镜像使用 `userdata`。
刷前核对目标设备、备份 `userdata` 和启动槽，并确认 sparse 文件
展开后能装入目标分区。

以下脚本只适用于允许覆盖两个启动槽和清空 `userdata` 的单系统设备。
如果有要保留的 Android 或 NixOS，请按[双系统指南](dual-boot.md)操作。

```sh
scripts/install-single.sh sheng-boot.img single-tty.sparse.img
fastboot reboot
```

新镜像启动后会扩展 ext4 根文件系统到现有分区边界。登录后用
`df -h /` 核对容量。

## 首启验收

1. 观察 U-Boot 菜单与倒计时，确认能够回到 ABL fastboot。
2. 确认内核启动，自动登录进用户 shell，或在关闭自动登录时出现 `login:` 且可以登录。
3. 登录后，用 `uname -r` 核对 7.3.4 内核，用 `findmnt /`
   核对实际根分区，并确认 `/gnu/store` 可读。
4. 记录 CI 链接、产物和实机结果。失败时记录最后看到的菜单或日志行。

当前镜像跳过 store DB 闭包注册，首次登录验证期间先不要依赖
`guix gc`。启动配置直接读取 store，U-Boot 的 `/boot/Image`
救援路径尚未接通。

## 相关配置

- 内核、DTB、固件和 U-Boot 配方在 `packages/`。
- `modules/sheng-bootloader.scm` 生成 extlinux 启动文件。
- `images/single-tty.scm` 和 `images/dual-tty.scm` 分别使用
  `userdata` 和 `linux`。

## 从 Guix 返回 ABL fastboot

运行 `sudo reboot`，在 U-Boot 菜单选择 `Reboot to fastboot (bootloader)`。
NixOS 的 `systemctl reboot --reboot-argument=bootloader` 属于 systemd
接口。TTY 镜像预装 ncurses，提供 `clear` 和 `reset`。
