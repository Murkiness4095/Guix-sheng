# 闭包更新与回退

已有 Guix 系统可以导入 CI 的签名闭包原地更新。保留现有数据和世代时，应选择与当前根分区匹配的闭包。刷写 sparse rootfs 会覆盖目标 ext4，连同其中的 `/var/guix`、系统世代和用户数据。

## 导入闭包

从同一次 CI 下载 `sheng-single-closures` 或 `sheng-dual-closures`。以下用 `single-niri` 举例。使用前核对 CI 和签名公钥的来源。

```bash
set -o pipefail
sha256sum -c SHA256SUMS &&
sudo guix archive --authorize < signing-key.pub &&
zstd -dc single-niri.nar.zst | sudo guix archive --import
```

如需 CI 使用的固定频道 Guix，可另外导入同包中的 `guix-*.nar.zst`。导入只把对象加入 store。切换命令由哪个 Guix profile 执行，仍取决于调用时使用的可执行文件。使用固定公钥时，在 CI 配置 `GUIX_ARCHIVE_SIGNING_KEY` 和 `GUIX_ARCHIVE_SIGNING_KEY_PUB`。

## 切换系统世代

`single-niri.system` 记录目标 store 路径。使用已加载 `guix-sheng` 频道、能识别 `sheng-extlinux` 的 Guix 执行仓库的切换脚本：

```bash
sudo env GUIX=/绝对路径/guix bash /绝对路径/guix-sheng/scripts/sheng-switch.sh "$(cat single-niri.system)"
```

脚本注册世代并调用 `guix system switch-generation`。Guix 会本地生成 extlinux 菜单。切换成功后，确认系统 profile 和默认启动项指向目标世代，再重启。遇到 `sheng-extlinux: no such bootloader` 时，检查实际使用的 Guix profile 是否包含 `gnu/bootloader/sheng.scm`。第 2 世代已通过手动更新 extlinux 启动，标准脚本路径仍待实机复验。

用 `guix system list-generations` 查看世代。新镜像、系统重配和仓库的闭包切换脚本都会生成 U-Boot 主菜单。用音量键选择世代，电源键启动。直接运行 Guix 的 `system roll-back` 或 `system switch-generation` 后，在重启前运行 `sudo bash scripts/sheng-bootmenu.sh` 刷新主菜单。

已有安装可以从仓库目录运行 `sudo bash scripts/sheng-bootmenu.sh --repair`，用现有的 Extlinux 启动项生成主菜单并关闭旧版数字输入提示。

## 更新个人配置

在个人 `channels.scm` 中更新 `guix-sheng` 的固定提交，再重新配置：

```sh
sudo -i guix time-machine -C /绝对路径/Guix-config/channels.scm -- \
  system reconfigure /绝对路径/Guix-config/system.scm
```

个人 Home 使用 `guix time-machine -C channels-home.scm -- home reconfigure home.scm`。系统闭包包含运行所需的 store 项，个人 Home 重新求值时仍可能需要构建输入。niri 系统预装 PCManFM-Qt 和 Qt Wayland 后端。个人 Home 配置可直接使用系统提供的文件管理器。
