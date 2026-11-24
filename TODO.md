# 待办与验收标准

- [ ] 首次 TTY 验收，关闭自动登录，确认出现 `login:` 并能登录。已有自动登录证据见[维护交接](docs/HANDOVER.md)。
- [ ] niri 登录修复验收，检查设备会话、120Hz、Noctalia 和输入设备。分别验证全新 rootfs 与闭包更新。
- [ ] 验证标准闭包切换和回退，确认旧世代可从 extlinux 菜单启动。
- [ ] 复验双系统安装、槽位切换和根分区保护。
- [ ] 验收 KDE、GNOME 和板级外设，按[外设验证](docs/peripheral-validation.md)记录实际交互结果。
