# 待办与验收标准（sheng 的 Guix 移植）

## 已完成

- [x] 项目骨架按目的创建
- [x] 职能聊天室 rooms/*（16 个）
- [x] 共享机制 shared/*
- [x] 实时工作台 scripts/workbench
- [x] Guix 包/模块/服务骨架
- [x] 内核/U-Boot/固件/音频/触摸/笔/指纹/电源/传感器/键盘等包骨架
- [x] 架构与参考文档

## 剩余待办

- [ ] channels.scm 锁定 Guix 提交并验证求值
- [ ] system.scm 可求值（guix system build）在 aarch64 CI
- [ ] 将包骨架替换为真实源码与构建
- [ ] 服务从骨架转为 shepherd 实现
- [ ] 单/双系统 6 种镜像（tty/kde/gnome）构建与刷写验证
- [ ] 双系统布局与切换
- [ ] 触摸/笔/音频/Wi-Fi/蓝牙验收
- [ ] 文档与交接更新
