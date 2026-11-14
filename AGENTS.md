# Working on Guix-sheng

- Read README.md, TODO.md, docs/HANDOVER.md first.
- System declarations live at the repo root: `images/`, `packages/`, `modules/`, `services/`.
- Do not silently upgrade board dependencies; pin commits and record evidence.
- Build-time identity: CI writes `images/settings.scm` from workflow inputs
  (`desktop_username`, `desktop_password`); local builds fall back to `sheng`.

## 移植基准（必须遵守，不再逐次确认）

- 功能、版本和实现顺序以 [debian-sheng](https://github.com/ianchb/debian-sheng)
  为第一参考：debian-sheng 已有的，先照做，不自行设计；debian-sheng 没有的，
  才用 Guix 自己实现。
- [nixos-sheng](https://github.com/Murkiness4095/nixos-sheng) 只作补充参考
  （启动槽、菜单、世代等 NixOS 特有机制）。
- 这是专有设备移植，不是自由软件发行版验收：固件、blob、专有内核配置、
  非自由组件按设备需要直接使用。Guix 的自由软件默认值不是约束，不得以
  “Guix 只有自由软件”为由删除或替换 debian-sheng 的功能。
- 内核源码固定为 [code002-2/sm8550-mainline](https://github.com/code002-2/sm8550-mainline)；
  配置用 debian-sheng 的 `sm8550.config`（固定提交，存放于
  `packages/kernel/sm8550.config`），按 debian-sheng 的方式用 clang/`LLVM=1`
  构建。
- 对齐结果与差异记录在 `docs/debian-alignment.md`；新增差异必须登记。
