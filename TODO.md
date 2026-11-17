# 待办

## 已验证

- [x] 单系统 tty 镜像曾用 stock Guix 1.5.0 构建成功
- [x] 频道拉取：`guix 3c50593` + `midnight 8e0dc3c`（约 30 分钟，含编译 Guix）
- [x] 镜像内 store DB 的 SQLite 锁绕过（`#:register-closures? #f`）
- [x] 仓库历史压缩、失败 CI 记录清理、单/双工作流拆分
- [x] 十种镜像求值：本地 `guix repl` 加载全部 `images/*.scm` 通过
      （Guix `1.5.0-unstable-2026-08-23` + midnight `8e0dc3c`；非 CI 的
      `--dry-run`）
- [x] 上游源哈希重算：内核 `0476xzvy…`、固件 `0hgz4s6g…` 原值正确；
      U-Boot 原值错误，改为 `1f713a5wzsnqmkj1g091rr4jfgfm15msc7aasyia35ai09g9bafx`
- [x] U-Boot fork 核对：SushyDev 与 Murkiness4095 的 `xiaomi-sheng` 均指向
      `7025b79`，`configs/sm8550_defconfig` 与 `board/qualcomm/sheng.env` 存在

## 进行中

- [ ] U-Boot 包真实构建（Zig MDSS + 两个补丁 + mkbootimg）
      （CI #43688501887 的重复 defconfig 项已补丁处理，待重跑）
- [ ] sheng 验证对应 NixOS-sheng 的 7.3.4 源码构建
- [ ] 固件包真实构建
- [ ] tty 镜像真实构建并产出 `sheng-boot.img` + `single-tty.sparse.img`
- [ ] 实机刷入与首启（判定见 `docs/boot-chain.md`）

## 待办

- [ ] collect-garbage 根：镜像注册 store DB（首启或改构建器）
- [ ] `/boot/Image`/dtb 复制，恢复 U-Boot `bootrescue` 路径
- [ ] 双系统：`boot-slot`、Android A / Guix B 切换脚本
- [ ] 桌面变体实机验证（kde/gnome/niri/noctalia）
- [ ] 外设验收：显示、触控、音频、Wi-Fi、充电、休眠

## 已知成本

- CI 冷启动需编译固定频道；暖启动可复用 Guix profile 闭包，见 [CI 缓存](docs/CI.md)。
- 内核与 U-Boot 各需一次完整构建，同 job 内复用。
