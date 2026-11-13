# Guix-sheng

Xiaomi Pad 6S Pro（代号 sheng）的 GNU Guix（aarch64）移植。设备支持参考
[nixos-sheng](https://github.com/Murkiness4095/nixos-sheng) 与
[debian-sheng](https://github.com/ianchb/debian-sheng)，软件包与模块按 Guix 原生方式重建。

## 仓库布局

系统本体：

| 路径 | 内容 |
| --- | --- |
| `channels.scm` | Guix 频道（guix、midnight、本地 Guix-sheng） |
| `system.scm` | 顶层 `operating-system` 示例 |
| `images/` | 单/双系统 × tty/kde/gnome/niri/noctalia 镜像声明 |
| `packages/` | 内核、U-Boot、固件、用户态包定义 |
| `modules/` | Guix 模块（硬件、启动、文件系统等） |
| `services/` | shepherd 服务定义 |
| `lib/` | 共享 Guile 辅助代码 |
| `scripts/` | 构建与工作台脚本 |
| `docs/` | 文档、交接、验证矩阵 |
| `tests/` | 配置/系统测试 |

协作脚手架（与系统声明分离）：

| 路径 | 内容 |
| --- | --- |
| `collab/rooms/` | 按职能划分的追加式记录通道 |
| `collab/shared/` | 共享约定、状态、锁 |
| `collab/workbench/` | 进度与待办工作台 |

## 当前验证状态

**只有一项通过 CI**，其余仍是骨架，不要把它当作可安装系统：

| 项目 | 状态 | 证据 |
| --- | --- | --- |
| `guix system build images/single-tty.scm` | ✅ 通过 | Actions run 43295518023 |
| `guix system image images/*.scm` | ❌ 失败 | 分区镜像构建器 SQLite `database is locked` |
| 内核/U-Boot/固件包 | ⚠️ 仅骨架 | 引用了上游源码，未构建 |
| 实机刷入/启动 | ⚠️ 未验证 | — |

`guix system image` 的失败发生在 `initialize-root-partition` →
`register-closure` → `call-with-database`，是 Guix 镜像构建器在沙箱文件系统上
WAL 锁不可用导致的，与板级声明无关。正在按 nixos-sheng 的
`make-ext4-fs.nix`（裸 ext4 + `img2simg`）思路规避。

## 快速开始

本地求值（只构建系统闭包，不生成镜像；已验证可行）：

```sh
git clone https://github.com/Murkiness4095/Guix-sheng.git
cd Guix-sheng
guix system build images/single-tty.scm
```

生成刷机镜像（**当前会失败**，见上表）：

```sh
guix system image images/single-tty.scm
```

CI 使用 GitHub ARM runner（`ubuntu-24.04-arm`），工作流见
`.github/workflows/build.yml`。

## 上游来源

| 组件 | 来源 | 版本/提交 |
| --- | --- | --- |
| 内核 | https://github.com/ianchb/sm8550-mainline | 分支 `sheng-7.3.0`，源提交 `1fb56e66091e71160d7c7f8e13b065d5b6ab8b8c`；配置 `sm8550.config` 取自 debian-sheng |
| U-Boot | https://github.com/SushyDev/u-boot | 分支 `xiaomi-sheng`，提交 `7025b792e2884c5fb4747d891e30002ea029048a`；另加 `packages/u-boot/patches/`（取自 nixos-sheng） |
| 固件 | https://github.com/ianchb/sheng-firmware | 分支 `master` |
| 用户态包 | debian-sheng / nixos-sheng | 见 `packages/firmware/*/` 与 `docs/reference.md` |

板级依赖不要静默升级；更新源码提交时同步记录证据。

## 协作脚手架

```sh
scripts/workbench          # 重新生成 collab/workbench/STATUS.md
scripts/workbench --watch  # 每 5 秒刷新
```

## 许可证

MIT。
