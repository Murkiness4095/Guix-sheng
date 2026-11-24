# Guix-sheng

小米平板 6S Pro 12.4（sheng）的 GNU Guix System 移植，使用板级 Linux 7.3.4、U-Boot 和 extlinux。板级实现参考 [nixos-sheng](https://github.com/Murkiness4095/nixos-sheng)，以 [debian-sheng](https://github.com/ianchb/debian-sheng) 补缺并交叉核对。

单系统 TTY 已验证启动并自动登录。niri 签名闭包已在实机导入并启动新世代，登录修复和旧世代菜单仍待复验。外设状态按功能记录在[外设验证](docs/peripheral-validation.md)。

| 你要做什么 | 从这里开始 |
| --- | --- |
| 首次安装、核对启动链 | [项目说明](docs/README.md)、[单系统安装](docs/boot-chain.md) |
| 保留现有 Android 或 NixOS | [双系统指南](docs/dual-boot.md) |
| 更新现有系统、切换世代 | [闭包更新与回退](docs/offline-updates.md) |
| 编写个人配置 | [最小样板](examples/minimal/README.md) |
| 开发、调试或接手维护 | [开发指南](docs/DEVELOPMENT.md)、[CI](docs/CI.md)、[维护交接](docs/HANDOVER.md) |
| 核对移植差异和待验收项 | [上游对照](docs/debian-alignment.md)、[待办](TODO.md) |

| Guix 根分区 | 工作流 | 配套开机镜像 | 根镜像示例 |
| --- | --- | --- | --- |
| `userdata` | `build-single` | `sheng-boot.img` | `single-tty.sparse.img` |
| `linux` | `build-dual` | `sheng-boot-dual.img` | `dual-tty.sparse.img` |

在 [GitHub Actions](https://github.com/Murkiness4095/Guix-sheng/actions) 选择工作流和 `main`。手动运行默认 `image=none`，导出 TTY 更新闭包。选择 `tty`、`niri`、`kde` 或 `gnome` 才生成可刷镜像，首次验收选 `tty`。push 和 PR 检查系统配置并导出闭包。手动构建默认账号和初始密码均为 `sheng`，自动登录和外设服务默认开启。

首次安装使用同一轮的开机镜像和根镜像。根镜像会覆盖目标分区。保留其他系统时，按双系统指南核对根分区和 A/B 槽。已有 Guix 系统可导入同布局的签名闭包原地更新。

许可证见 [LICENSE](LICENSE)。
