# 项目说明

sheng 的 GNU Guix（aarch64）移植。仓库按职责分层：

| 路径 | 用途 |
| --- | --- |
| `channels.scm` | 频道：固定 Guix + midnight（noctalia） |
| `images/` | 镜像声明与共享 OS 生成器 `base.scm` |
| `packages/` | 内核、U-Boot、固件、用户态包定义 |
| `modules/` | Guix 模块（硬件、启动、文件系统、桌面） |
| `services/` | shepherd 服务定义 |
| `lib/` | Guile 辅助代码 |
| `scripts/` | 构建与镜像提取脚本 |
| `examples/` | 个人配置样板 |
| `tests/` | 配置/系统测试 |
| `docs/` | 交接、架构、验证文档 |

镜像产物：单系统与双系统各四种（tty/niri/kde/gnome）。桌面变体
KDE 用 SDDM，GNOME 用 GDM，niri 用 noctalia greeter，tty 变体保留
文本 getty。构建入口见
`.github/workflows/build-single.yml` 与 `build-dual.yml`，本地构建需要
`guix system image -L . images/<variant>.scm`。

启动链（U-Boot → extlinux → tty）与刷机步骤见
[boot-chain.md](boot-chain.md)。
