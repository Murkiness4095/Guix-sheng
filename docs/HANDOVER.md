# 维护交接

## 当前状态

- 启动链已实现：`packages/u-boot.scm`（fork + 补丁 + mkbootimg）、
  `modules/sheng-bootloader.scm`（extlinux.conf）、`images/base.scm` 接入
  `linux-sheng`、`sheng-firmware`。
- 十种镜像已用本地 `guix repl` 求值通过；CI 实际构建尚未跑。
- 硬件包源哈希已核对：内核/固件原值正确，U-Boot 已修正。
- 实机刷入、首启、外设：未开始。

## 关键结论

- U-Boot fork 的两个远端（SushyDev、Murkiness4095）`xiaomi-sheng` 指向同一提交
  `7025b79`；本仓库固定该提交。
- U-Boot 的 `boot.img` 必须用 `--header_version 2`，并带 `u-boot.dtb`；
  cmdline 含 `root=PARTLABEL=userdata`（双系统为 `linux`）。
- 双系统 U-Boot 必须同时改 `board/qualcomm/sheng.env` 的 sysboot 分区名和
  rescue 的 `root=PARTLABEL=`，只改 boot.img cmdline 不够。
- Guix 默认 `root-partition` 已关闭 `metadata_csum`/`64bit`，U-Boot 可读。
- 镜像 root 分区从 1 MiB 偏移提取；ext4 卷标与分区标签同为 `userdata`。
- `guix system image --dry-run` 之前必须加 `-L <仓库根>`，否则
  `(packages ...)`/`(modules ...)` 无法解析。

## 下一步

1. 触发 `build-single`，确认 U-Boot、内核、固件、tty 镜像构建。
2. 按 `docs/boot-chain.md` 刷入并完成首启验收。
3. 建立 store DB 注册，恢复 `bootrescue` 路径。
4. 双系统与桌面变体。
