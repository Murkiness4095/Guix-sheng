# sheng 最小个人配置

此样板在仓库内复用 `images/base.scm` 的 TTY 配置，使用 sheng 内核、
固件和 extlinux。默认 ext4 卷标为 `userdata`，对应单系统开机镜像。
双系统将 `#:root-label` 改为 `"linux"`，并使用指向 `linux` 的 dual
开机镜像。这个参数设置 Guix 查找的 ext4 卷标，U-Boot 则查找 GPT 分区名。

在仓库根目录、已加载仓库 `channels.scm` 的 GitHub Actions 或隔离环境里验证：

```sh
guix system build -L . examples/minimal/system.scm
```

需要可刷产物时从 Actions 构建对应的 `tty` 镜像。这个样板是系统声明，
由它执行的 `guix system build` 只产生系统闭包。
实机验证参见[启动链](../../docs/boot-chain.md)。
