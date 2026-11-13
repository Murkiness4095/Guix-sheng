# sheng 双系统样板

保留 Android（A 槽 / `userdata`），Guix 安装在 B 槽的 `linux` 分区。
根分区按 PARTLABEL 定位，不要在多个分区之间复制固定 UUID。

与单系统的唯一结构差异：根文件系统为

```scheme
(file-system
  (mount-point "/")
  (device (file-system-label "linux"))
  (type "ext4"))
```

刷写前确认模式与槽位：

```sh
fastboot getvar current-slot
```

Android OTA 自动保留 Linux 不在本项目范围内；接受选择性重刷 Android。
不要使用会擦写 `userdata` 或同时写两个 boot 槽的旧通用脚本。
