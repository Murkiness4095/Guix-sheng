# 待办

## 已验证

- [x] 单系统 tty 镜像构建成功（CI）
- [x] SQLite 锁绕过（`#:register-closures? #f`）
- [x] 仓库历史压缩、CI 历史清理

## 进行中

- [ ] 单/双系统 × tty/kde/gnome/niri/noctalia 十个镜像全部构建
- [ ] `base.scm` 在 CI 求值通过（niri + midnight + greetd）
- [ ] 构建时用户名/密码写入镜像并生效

## 待办

- [ ] 内核包替换为 `sm8550-mainline` 实际构建
- [ ] U-Boot 包与补丁实际构建
- [ ] 固件包实际构建
- [ ] 镜像内 store DB 注册（首启或改 Guix 镜像构建器）
- [ ] 实机刷入、启动、触摸/笔/音频/Wi-Fi/蓝牙验收
