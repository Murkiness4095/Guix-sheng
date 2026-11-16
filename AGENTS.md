# Working on Guix-sheng

- Read README.md, TODO.md, docs/HANDOVER.md first.
- System declarations live at the repo root: `images/`, `packages/`, `modules/`, `services/`.
- Do not silently upgrade board dependencies; pin commits and record evidence.
- Build-time identity: CI writes `images/settings.scm` from workflow inputs
  (`desktop_username`, `desktop_password`); local builds fall back to `sheng`.

## 移植基准（必须遵守，不再逐次确认）

- 优先参考 [nixos-sheng](https://github.com/Murkiness4095/nixos-sheng)。已有板级实现直接复用，记录参考提交。
- [debian-sheng](https://github.com/ianchb/debian-sheng) 用于补缺和交叉核对。系统声明、initrd 和服务接线按 Guix 接口适配。
- 这是专有设备移植，不是自由软件发行版验收：固件、blob、专有内核配置、
  非自由组件按设备需要直接使用。Guix 的自由软件默认值不是约束，不得以
  “Guix 只有自由软件”为由删除或替换 debian-sheng 的功能。
- 内核按 [nixos-sheng 配方](https://github.com/Murkiness4095/nixos-sheng/blob/2be57fe7da35b0b98963cc5da233ad6765d5c134/packages/kernel/default.nix)从 `ianchb/sm8550-mainline` 源码构建，固定源码提交、配置和源码修改。
- 对齐结果与差异记录在 `docs/debian-alignment.md`；新增差异必须登记。

## 构建与验收

1. 先读交接记录和最近一次相关 CI 日志，定位第一个实际失败的步骤。检查 NixOS 参考实现，针对该步骤做最小修改并记录差异。
2. 构建优先走 GitHub Actions。需要本地复现时使用隔离的 Nix 环境。禁止在宿主机安装 Guix、运行 `guix pull` 或启动 Guix daemon。
3. 首轮仅用 `build-single` 的 `variants: single-tty`。跟踪运行到结束，失败时检查首个实际失败步骤，通过时检查同一 run 的 `sheng-boot.img` 和 `single-tty.sparse.img`。
4. 将 CI 链接和产物状态写入交接记录。设备出现 `login:` 并能登录后，才将 TTY 标为验收完成。首轮验收后再扩展到双系统、桌面和外设。
