# 待办

## 已验证

- [x] 单系统 tty 镜像构建通过（旧配置，Guix 1.5.0）
- [x] 镜像内 store DB 注册的 SQLite 锁绕过（`#:register-closures? #f`）
- [x] 仓库历史压缩为单条提交；CI 历史清理
- [x] single/dual 工作流拆分，编号从 #1 开始

## 进行中

- [ ] `guix pull` 固定频道（Guix master + midnight）在 CI 的耗时验证
- [ ] 单/双系统 × tty/kde/gnome/niri/noctalia 十个镜像全部构建
- [ ] 构建时用户名/密码注入镜像并验证

## 待办

- [ ] 去掉 `pull-test.yml` 诊断工作流
- [ ] 内核包替换为 sm8550-mainline 实际构建
- [ ] U-Boot 包与补丁实际构建
- [ ] 固件包实际构建
- [ ] 镜像内 store DB 注册（首启或改 Guix 镜像构建器）
- [ ] 实机刷入、启动与外设验收

## 已知问题

- Guix 官方 Savannah Git 在 CI 报 `SSL error: syscall failure`；已改用
  Codeberg 镜像并固定提交。
- 固定提交若无现成 substitute，`guix pull` 会本地编译 Guix，较慢。
