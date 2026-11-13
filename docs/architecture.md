# 架构

```
channels.scm          guix master + midnight
images/
  base.scm            共享 OS 生成器（greetd + noctalia greeter + librewolf）
  single-*.scm        单系统镜像（根 userdata）
  dual-*.scm          双系统镜像（根 linux）
packages/             内核 / U-Boot / 固件 / 用户态
modules/              OS 片段
services/             shepherd 服务
scripts/build-image.sh  guix system image + 提取 ext4 分区
examples/             最小 / 桌面 / 双系统 / 多机 / tmpfs
```

镜像由 `(image (inherit mbr-disk-image) ...)` 生成，root 分区 initializer
以 `#:register-closures? #f` 跳过镜像内 store DB 注册（规避 CI 沙箱的
SQLite 锁），闭包仍被复制；分区从 1 MiB 偏移处提取为 ext4。
