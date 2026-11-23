# 维护交接

## 当前状态
- [#44381881864](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44381881864) 与 #44366125828 均在 Thunar 4.20.10 的 bootstrap 遭遇 autogen.sh 执行权限错误。改用同版本的 Xfce 正式源码归档及随附 configure，保留 GVfs。
- [#44263012512](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44263012512) 的单系统 TTY 镜像已通过闭包注册、SQLite 完整性与引用检查、启动世代注册检查和 ext4 写回检查，并上传 `sheng-boot.img` 与 `single-tty.sparse.img`。实机新世代切换与回滚待验证。已刷入的旧 GNOME 不受这次镜像修复影响。
- [#44256485674](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44256485674) 已在镜像外打开 SQLite 并读到 571 个 store 项，但注册时间误传整数，Guix 要求 SRFI-19 日期。改用 UTC epoch 日期，并在单系统 CI 构建前用相同的 Guix 和注册器验证一个小闭包。
- [#44254594748](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44254594748) 已生成 TTY 磁盘并提取两个引用图，外部注册脚本因 `register-closure` 私有绑定不可用退出。改用 Guix 的数据库和引用图接口，并用单文件提取避免 `rdump` 修改属主。
- [#44242273958](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44242273958) 已通过键盘认证依赖构建，复制 572 个 store 项后，Guix 镜像沙箱内注册闭包报 SQLite `database is locked`。改在提取 ext4 后、沙箱外按原始引用图注册并检查启动世代，再写入数据库。旧镜像的注册需另行恢复。
- 键盘认证首轮 [#44241262865](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44241262865) 在 `patchelf` 处理 QTEE 的 `sfs_config` 脚本时失败。改由 Shepherd 调用 Guix coreutils 创建上游要求的两个目录，复验并入上面的 TTY CI。
- 键盘和触控板同时失灵时，实机仍显示 `keyboard_attached=1`，每约 12 秒的唤醒写入返回 0。IRQ 读到有效的厂商帧 `0x22`，已看到子命令 `0xf0`、`0x28`、`0x25`、`0x64`，没有看到键盘 `0x05/0x06` 或触控板 `0x19` 报告。故障窗口未看到驱动处理的认证子命令 `0x24/0x31/0x32`，内核日志也无认证超时。Guix GNOME 有 `/dev/nanosic_auth` 和 `/dev/tee0`，但没有运行 NixOS-sheng 的键盘认证服务。认证服务缺失是移植差异，尚未证明它触发本次故障。抓取完成后重绑，两个 HID 设备重新枚举。
- Nanosic 诊断内核 [#44228797818](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44228797818) 构建通过。现有 GNOME 的 7.3.4 内核也能用 tracefs 实时检查键盘报告头与 HID 投递，无需切换镜像。正常时实机按 Shift 观察到 I²C 返回 0、帧头 0x57、报告类型 0x05，随后调用 `hid_input_report`。独立环形缓冲 `/sys/kernel/debug/tracing/instances/sheng_kbd/trace` 保留诊断记录，探针只读返回值和帧头的三个字段。复发时应在重绑前比对同样的按键动作。尚未确认永久修复。
- 键盘失灵时 HID 仍绑定，按 Shift 无输入事件。经 SSH 重绑 `nanosic_wn8030` 的 `2-004c` 后，键盘和触控板重新枚举，键盘事件恢复且实机确认可用。触发原因待定位。
- 实机 TTY 通过 SSH 核对到本地活动会话可激活 NetworkManager 连接，但系统连接编辑要求认证。已在实机验证本地活动 `netdev` 规则通过 `pkcheck`，同一规则接入镜像。键盘 HID 与 Nanosic I²C 设备状态通过 SSH 观察，失灵时的状态待捕获。
- `userdata` / A 槽实机首启通过：清空 `dtbo_a` 后经 extlinux 自动登录 tty1，`fastfetch` 确认 Guix System 及 Linux 7.3.4-sm8550。使用 [#44065603032](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44065603032)。WCD938x 耳机阻抗检测报错待排查。
- 实机首刷 #44058228439 后未进入 Guix；本地展开其 sparse 根镜像，ext4 主超级块无效。CI 改用实际分区表提取并检查 extlinux。已通过串口确认平板回到 NixOS，仍使用 `linux` 和原有 ESP。
- [外设集成 TTY #44058228439](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44058228439) 成功上传开机和根镜像。实机待验。
- [单系统 TTY #44044743355](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44044743355) 已成功上传配对产物。实机登录待验证。

- 本地 `main` 基于 `origin/boot-chain` 的 `7accabd`。U-Boot defconfig 去重补丁已用固定提交的原始配置验证，完整构建待跑。
- 内核按 NixOS-sheng 的 7.3.4 配方从源码构建，待单系统 CI 验证。
- [开机镜像 #43949538335](https://github.com/Murkiness4095/Guix-sheng/actions/runs/43949538335) 构建通过，已下载并确认 Android 镜像头。
  `sheng-boot.img` SHA-256 为 `d7e24316eb1eb11dcd2c9b724fee1a47099061245310cf237aa45b923665dd31`。根镜像与实机登录待验证。
- 最近一次板级构建是 [build-single #43688501887](https://github.com/Murkiness4095/Guix-sheng/actions/runs/43688501887)，提交 `e69add6`。U-Boot 因 `CONFIG_CLK_QCOM_SM8550=y` 重复而中止，根镜像构建未执行，未上传镜像。
- 十种镜像有本地求值通过记录。旧骨架曾产出根镜像，当时尚未接入 sheng 内核。当前尚无板级可刷产物和实机登录记录。

## 接手后的第一轮验收

1. 用包含去重补丁的分支触发 `build-single`，输入 `image=tty`。
2. 跟踪到构建结束。同一个 run 应产出 `sheng-boot.img` 和 `single-tty.sparse.img`。将 run 链接和产物状态更新到本页。
3. 按[启动链](boot-chain.md)进行实机验收，记录是否到达 `login:`、能否登录以及对应镜像的 run。后续工作见 [TODO](../TODO.md)。

## 2026-11-22 Niri 实机会话修复

Guix 实机 192.168.1.122 的 niri 配置只有 noctalia 启动行，缺少默认快捷键、用户 D-Bus 和音频会话。通过 SSH 补起共享用户总线、PipeWire、pipewire-pulse、WirePlumber、手写笔托盘和麦克风静音辅助程序。D-Bus 已返回注册的 StatusNotifierItem，wpctl 已列出扬声器、耳机、麦克风。实际播放、笔电量更新和重启持久化待验收。

Zed 日志报告无法创建 surface。指定当前 Mesa 的 Freedreno Vulkan ICD 后，niri 窗口列表出现 `dev.zed.Zed`。实机增加用户 desktop 覆盖，仓库为 Zed editor 封装驱动路径。Niri 登录入口统一使用 dbus-run-session，默认配置加载后按顺序启动音频服务与外设程序。参考 NixOS-sheng 仍固定 `2be57fe7da35b0b98963cc5da233ad6765d5c134`。

## 2026-11-22 配置并入镜像与充电复核


撤销个人桌面资源并入：删除壁纸、logo、Noctalia 个人配置与整份个人 niri 配置，移除首次激活复制服务。设备仓库恢复上游 niri 默认配置，仅追加 DSI-1 120Hz 和设备会话接线。个人配置继续由独立 Guix-config 管理。

## 2026-11-22 补齐参考模块接线

复核远程 NixOS-sheng main 仍为固定基准 2be57fe。新增 qbootctl 固定包和 Shepherd 启动成功标记、USB serial getty、所有变体的 DSI-1 120Hz 内核请求、KDE SDDM Qt6 虚拟键盘插件。MiPPS Python 调度改为请求 Shepherd，保留上游 USB online debounce 与断线通知清理。源文件语法与 diff 检查通过，充电补丁 dry-run 通过；按用户要求未启动构建，所有新路径待 CI 和实机验证。完整模块矩阵见 debian-alignment.md 最后一节。

## 2026-11-22 构建期间桌面失去响应

USB 仍可执行命令。观测 load 约 23、15GiB 内存已用 14GiB，可用约 341–361MiB，无 swap，至少 8 个 cc1plus 同时运行并处于 D 状态。发送中断 Home reconfigure 请求后，后续 ps 未再列出编译进程。检查中还存在 shutdown 进程，随后 USB 断开，未确认桌面恢复。未由 agent 发起关机。Guix daemon 默认追加 --cores=2 --max-jobs=1，限制默认构建并行，待应用配置后生效。

## Niri 闭包 #45039183456

https://github.com/Murkiness4095/Guix-sheng/actions/runs/45039183456 在 Evaluate all images 阶段失败，未生成 niri rootfs 或闭包。相机模块错误地从 (gnu packages video) 选择 libcamera，固定 Guix 3c50593 的定义位于 (gnu packages photo)，修正导入。U-Boot 步骤已通过，不能视作根系统构建通过。

#45039916915（双系统 push）已通过求值，qbootctl configure 失败：codeload URL 的下载名称为 0.2.2，没有归档后缀，Guix unpack 未展开源码。给 origin 显式设置 qbootctl-0.2.2.tar.gz，源码与哈希保持不变。

[单系统 niri #45041217603](https://github.com/Murkiness4095/Guix-sheng/actions/runs/45041217603) 的镜像步骤耗时约 3 小时 16 分钟，`niri-default-config` 的单文件来源触发 Guix `install-license-files` 阶段的匹配错误，rootfs 与签名闭包未生成。Guix profile 和内核缓存命中，niri store 闭包因完整键变化未命中。跳过该单文件包的许可证扫描，并允许回退导入同架构同变体的旧闭包，镜像成功后仍按当前键保存。
