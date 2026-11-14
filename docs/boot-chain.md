# 启动链（tty 首启）

目标：U-Boot（boot_a/boot_b）→ extlinux → 单系统 tty 镜像启动。

## 组件与来源

| 组件 | 实现 |
| --- | --- |
| U-Boot | `packages/u-boot.scm`，SushyDev/u-boot `xiaomi-sheng` 提交 `7025b79`，两个 nixos-sheng 补丁 |
| boot.img | 同包 `build-boot-image` 阶段，调用 `packages/mkbootimg-v2.py` |
| extlinux.conf | `modules/sheng-bootloader.scm`，写入 `/boot/extlinux/extlinux.conf` |
| 内核 | `packages/kernel.scm`，`sm8550-mainline` 提交 `1fb56e6` + debian-sheng `sm8550.config` |
| 固件 | `packages/firmware.scm`，`ianchb/sheng-firmware` |
| 根分区 | `images/single-tty.scm`，ext4 卷标/分区名 `userdata` |

U-Boot 的默认环境执行：

```
scsi scan && part number scsi 0 userdata partnum &&
sysboot scsi 0:${partnum} any ${pxefile_addr_r} /boot/extlinux/extlinux.conf
```

Guix 生成的 extlinux.conf 指向 store 中的 `Image`、`initrd` 和
`lib/dtbs/qcom/sm8550-xiaomi-sheng.dtb`，APPEND 含 `root=userdata` 与
`gnu.system=`/`gnu.load=`。U-Boot 通过 ext4load 直接读取根分区上的 store。

boot.img 由 `packages/mkbootimg-v2.py` 生成。Guix 自带的 `mkbootimg` 是
Android 7.1.2 版本，只有 header v0，没有 `--dtb`/`--header_version`，ABL
不认；本仓库的 v2 writer 在相同参数下与 AOSP `mkbootimg.py` 逐字节一致
（kernel、dtb、cmdline、base/offsets、page size 均相同）。

## 构建

```sh
scripts/build-uboot.sh single      # -> sheng-boot.img
scripts/build-image.sh images/single-tty.scm   # -> single-tty.ext4 / .sparse.img
```

两个脚本都给 `guix` 传 `-L <仓库根>`，镜像文件依赖本地 `(packages ...)`
和 `(modules ...)`。

## 刷入（会清除 Android）

```sh
scripts/install-single.sh sheng-boot.img single-tty.sparse.img
fastboot reboot
```

脚本只写 `boot_a`、`boot_b`、`userdata` 三个字面量分区，校验 boot.img 的
`ANDROID!` 魔数、rootfs 的 sparse/ext4 魔数，并要求恰好一个 fastboot 设备。

## 验收判据

1. 屏幕出现 U-Boot 菜单（5 秒倒计时）。
2. 串口/屏幕看到 `sysboot` 后内核启动日志。
3. `uname -r` 以 `7.3.0` 开头（带 extra version，具体后缀以构建为准）。
4. 根文件系统以 `userdata` 挂载，`/gnu/store` 可读。
5. 失败时 U-Boot 静态菜单仍能进入 fastboot（`Reboot to fastboot`）。

## 已知技术债

- 镜像跳过 store DB 注册（`#:register-closures? #f`），首次启动的
  `guix-daemon` 会自己初始化数据库；GC 根尚未建立，不能依赖 `guix gc`。
- extlinux.conf 直接引用 store 路径，未复制 `Image`/dtb 到 `/boot`，因此
  U-Boot 的 `bootrescue` 路径（`/boot/Image`）暂不可用。
- 内核按 debian-sheng 配置构建；`CONFIG_LTO_CLANG` 等在 GCC 构建下会被
  `oldconfig` 关闭，与 Debian 产物不完全相同。
- arm64 的 `all` 目标不构建 dtbs，`linux-sheng` 额外执行 `make dtbs`，
  否则 `lib/dtbs/qcom/sm8550-xiaomi-sheng.dtb` 不存在。
