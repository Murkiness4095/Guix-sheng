# 维护交接

## 当前状态
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
