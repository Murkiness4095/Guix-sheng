# 待办

## 已验证

- [x] 单系统 tty 镜像曾用 stock Guix 1.5.0 构建成功
- [x] 频道拉取：`guix 3c50593` + `midnight 8e0dc3c`（约 30 分钟，含编译 Guix）
- [x] 镜像内 store DB 的 SQLite 锁绕过（`#:register-closures? #f`）
- [x] 仓库历史压缩、失败 CI 记录清理、单/双工作流拆分

## 进行中（逐个修复镜像求值）

- [x] `pipewire-service-type`：Guix 无系统级服务，已移除
- [x] `(guix packages)`：补导入
- [x] `noctalia-greeter`：补 `(midnight packages noctalia-greeter)`
- [x] `openssh-service-type`：补 `(gnu services ssh)`
- [ ] 十种镜像求值通过（含快速 `--dry-run` 检查）
- [ ] 十种镜像实际构建并上传 artifact

## 待办

- [ ] 推送本地内核/固件接入（self channel）
- [ ] 内核用 `customize-linux` + sm8550 配置实际构建
- [ ] U-Boot 用 `make-u-boot-package "sm8550"` 实际构建
- [ ] 固件包实际构建
- [ ] 镜像内 store DB 注册（首启或改构建器）
- [ ] 实机刷入、启动、外设验收

## 已知成本

- 每次 CI 冷启动 `guix pull` 约 30 分钟；`guix archive` 缓存不可用（签名密钥在 /etc/guix）。
