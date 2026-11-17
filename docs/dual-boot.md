# 双系统安装指南

ABL 按启动槽加载各系统自己的开机镜像。Guix 工作流名称决定
U-Boot 查找的根分区，与设备上装了几个系统无关。

| 已有系统 | Guix 根分区 | 同一次 CI 的 Guix 产物 |
| --- | --- | --- |
| NixOS 在 `linux` | `userdata` | `build-single` 的 `sheng-boot.img` 和 `single-tty.sparse.img` |
| Android 或 NixOS 在 `userdata` | `linux` | `build-dual` 的 `sheng-boot-dual.img` 和 `dual-tty.sparse.img` |

## 保留 linux 上的 NixOS

[单系统 TTY CI](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44044743355)
已产出 Guix 所需的两个文件。先确认 NixOS 当前根分区、启动槽和 ESP
实际位置。比如 NixOS 占用 B 槽，就保留 `boot_b`、`linux`
和它的 ESP，Guix 用 `boot_a` 与 `userdata`。如果 NixOS 占用 A
槽，就交换两个启动槽，根分区选择不变。

只有确认 NixOS 的启动文件无需从 `userdata` 读取后，才覆盖该分区。
先备份目标启动槽与 `userdata`，并核对 sparse 根镜像展开后能放进
缩小后的分区。可以先写 Guix 根镜像并临时加载开机镜像验证，
通过[首启验收](boot-chain.md#首启验收)后再写入 Guix 使用的启动槽。
之后通过 ABL 切槽，验证两个系统都能进入。

`scripts/install-single.sh` 会同时覆盖两个启动槽，不能用于这套
共存布局。Guix 的实机首启和切槽待验证。
