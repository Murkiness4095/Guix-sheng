# 项目说明

sheng 的 GNU Guix（aarch64）移植。仓库按职责分层：

| 路径 | 用途 |
| --- | --- |
| `channels.scm` | 频道：Guix master + midnight（noctalia） |
| `images/` | 镜像声明与共享 OS 生成器 `base.scm` |
| `packages/` | 内核、U-Boot、固件、用户态包定义 |
| `modules/` | Guix 模块（硬件、启动、文件系统、桌面） |
| `services/` | shepherd 服务定义 |
| `lib/` | Guile 辅助代码 |
| `scripts/` | 构建与镜像提取脚本 |
| `examples/` | 个人配置样板 |
| `tests/` | 配置/系统测试 |
| `docs/` | 交接、架构、验证文档 |

镜像产物：单系统与双系统各五种桌面（tty/kde/gnome/niri/noctalia），
统一 noctalia greeter 登录、librewolf 浏览器。构建入口见
`.github/workflows/build-single.yml` 与 `build-dual.yml`。
