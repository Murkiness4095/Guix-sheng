# 配置样板

| 你要做什么 | 从这里开始 |
| --- | --- |
| 最小可启动单系统 | [minimal](minimal/) |
| 桌面系统（niri + noctalia + librewolf） | [desktop](desktop/) |
| 保留 Android 的双系统 | [dual-boot](dual-boot/) |
| 多机部署（对应 NixOS flake-parts） | [multi-host](multi-host/) |
| 易失根 + 选择性持久化 | [tmpfs-root.scm](tmpfs-root.scm) |

样板只增加个人设置；内核、U-Boot、固件与根分区约定由仓库的 `images/base.scm`
和 `packages/` 提供。不要把 x86 的 GRUB/EFI、NVIDIA 或整盘分区配置带进来。

```sh
guix system build system.scm
sudo guix system reconfigure system.scm   # 设备上
```

`reconfigure` 不会更新 U-Boot；U-Boot 仍需单独刷写。
