# 维护交接

## 当前状态

- 单系统 tty 镜像构建已通过 CI。
- 单/双系统各五种桌面变体已加入矩阵，正在验证。
- 仓库历史已压缩为单条提交；CI 历史仅保留成功运行。
- 硬件（内核/U-Boot/固件）包仍是骨架，引用上游源码，未实机验证。

## 关键结论

- `guix system image` 在镜像内注册 store DB 时会在 CI 沙箱触发 SQLite
  `database is locked`；用 `#:register-closures? #f` 跳过，闭包仍复制。
- niri 在 Guix 官方 `(gnu packages window-management)`；noctalia 与
  noctalia-greeter 在 midnight 频道。
- 镜像 root 分区从 1 MiB 偏移提取；双系统根标签 `linux`，单系统 `userdata`
  （当前镜像统一用 `linux`，见 TODO）。

## 下一步

1. 十种镜像全部构建通过。
2. 内核/U-Boot/固件包替换为真实构建。
3. 实机刷入与启动、外设验收。
