# sheng 最小个人配置

`system.scm` 通过 `(sheng system)` 使用 sheng 内核、固件和 extlinux。
它定义 TTY、主机名 `guix` 和登录用户 `sheng`，默认用 `userdata`。
使用 `linux` 时改成 `#:root-label "linux"`，并配对 dual 开机镜像。
如需密码登录，给 `sheng-os` 传 `#:password-hash`，其中是密码哈希。
可用 `#:auto-login? #f` 关闭自动登录。

在 Guix 设备或隔离构建环境，从样板所在目录运行：

```sh
guix time-machine -C channels.scm -- system build system.scm
```

复制 `channels.scm` 和 `system.scm` 即可作为独立个人配置。频道锁定
Guix、Midnight 和 Guix-sheng 的提交。在本仓库开发时，也可以在仓库根用
已加载 Guix 和 Midnight 的环境运行 `guix system build -L . examples/minimal/system.scm`。

首次安装请使用对应的 CI 镜像。构建系统闭包不会生成可刷镜像。
已安装系统的原地更新用 `guix system reconfigure`，须先确认 store
已正确注册旧世代。刷写和启动验证见[启动链](../../docs/boot-chain.md)。
