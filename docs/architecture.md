# 架构

```
channels.scm          guix master + midnight
images/
  base.scm            共享 OS 生成器（SDDM/GDM/noctalia greeter + librewolf）
  single-*.scm        单系统镜像（根 userdata）
  dual-*.scm          双系统镜像（根 linux）
packages/             内核 / U-Boot / 固件 / 用户态
modules/              OS 片段
services/             shepherd 服务
scripts/build-image.sh  guix system image + 提取 ext4 分区
examples/             最小 / 桌面 / 双系统 / 多机 / tmpfs
```

镜像由 `(image (inherit mbr-disk-image) ...)` 生成。根分区初始化时复制
store 闭包并保留 Guix 生成的引用图。提取 ext4 后，构建脚本在镜像沙箱外
注册闭包，检查数据库完整性、引用一致性和 extlinux 指向的系统注册，
再把数据库写入 ext4 并生成 sparse 产物。
已刷入的旧镜像需要单独恢复闭包注册。
