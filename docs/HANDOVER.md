# 维护交接

## 当前状态
- 已发布镜像仍跳过 store 闭包注册。提交 `377b839` 恢复所有根镜像的闭包注册并保留 SQLite 非 WAL 模式，构建脚本在生成 sparse 前验证 SQLite 与 extlinux 启动世代。验证运行 [#44242273958](https://github.com/Murkiness4095/Guix-sheng/actions/runs/44242273958)，产物及实机更新待验。
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
