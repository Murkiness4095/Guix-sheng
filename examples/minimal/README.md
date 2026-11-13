# sheng 最小个人配置

默认单系统：根分区为 `userdata`，不安装桌面。双系统请把
`(file-system-label "userdata")` 改为 `"linux"`，或直接参考 [dual-boot](../dual-boot/)。

硬件、内核、DTB、U-Boot 与固件由仓库提供；本样板只增加主机名、用户和 root 分区。
保留仓库锁定的频道提交可获得与 CI 相同的基线；更新频道属于单独的验证步骤。

首次构建：

```sh
guix system build system.scm
sudo guix system init system.scm /mnt   # 仅在空目标上
```

设备上日常更新用 `sudo guix system reconfigure system.scm`。U-Boot 不随 reconfigure 更新。
