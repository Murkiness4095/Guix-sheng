# 双系统安装指南

布局对应 NixOS-sheng 的独立 `linux` 根分区做法。ABL 在两个启动槽之间
切换，两个系统各自保留自己的开机镜像。以下以 NixOS 已占用 A 槽为例。

| ABL 槽位 | 系统 | GPT 根分区名 | 启动文件 |
| --- | --- | --- | --- |
| A | 现有 NixOS | `userdata` | 保留原 `boot_a` 和已有 EFI 文件 |
| B | Guix System | `linux` | Guix 的 `sheng-boot-dual.img` |

如果现有系统在 B 槽，保留 B 槽并用 A 槽装 Guix。保留 Android 时
同样先确认它实际占用的槽。原来安装 NixOS 时选择的工作流名称无法证明
当前使用哪个槽。

## 准备产物和核对分区

1. 用 `build-dual` 的 `image=tty` 构建，取得同一 run 的
   `sheng-boot-dual.img` 和 `dual-tty.sparse.img`。
2. 在现有系统确认根挂载与 GPT 标签，进入 ABL fastboot 后用
   `fastboot getvar current-slot` 核对槽位。检查目标 `linux` 可覆盖，
   并确认 sparse 展开大小小于等于目标分区容量。
3. 备份目标启动槽和 `linux` 上需保留的数据。已有 EFI 的 NixOS
   同时核对 ESP 位置，保留现有 ESP。Guix 的 extlinux 路线无需另建 ESP。

## 部署和切换

先将 Guix 根镜像写入 `linux`，有条件时用 ABL 的临时启动加载
`sheng-boot-dual.img` 验证。确认进到 `login:` 并能登录后，再将
开机镜像刷到 Guix 对应的槽。下次在 ABL fastboot 用
`fastboot set_active a` 或 `fastboot set_active b` 选择对应系统。

`scripts/install-single.sh` 会写两个启动槽并擦除 `userdata`，
不能用于这套共存布局。Guix 双系统的实机登录和切槽仍待验证。
启动后按[首启验收](boot-chain.md#首启验收)核对实际根分区。
