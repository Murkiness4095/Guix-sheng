# CI 设计

## 工作流

- `build-single`：单系统镜像（tty/niri/kde/gnome）
- `build-dual`：双系统镜像
- push/PR 只构建 `tty` 变体；手动运行用 `image` 选择单个变体，四个桌面
  变体不再在每次 push 时串行构建。
- 每条工作流是**单个 job**：`guix pull -C channels.scm` 一次，手工运行时
  只构建所选变体。相同分支的新 run 取消旧 run。
- 触发路径：`images/**`、`scripts/**`、`channels.scm`、对应 workflow 文件。

## 频道

`channels.scm` 固定提交：

- `guix`：`codeberg.org/guix/guix.git`（Savannah 在 CI 报
  `SSL error: syscall failure`），提交 `3c50593f...`（含 niri）。
- `midnight`：`codeberg.org/stampede/midnight.git`（noctalia、noctalia-greeter）。

固定提交可复现；若该提交没有现成 substitute，`guix pull` 会本地编译 Guix。

## 缓存

- 上游包继续使用 Guix 默认 substitutes。
- `guix-state` 缓存频道 checkout 和用户配置。它命中时，干净 runner 仍缺少
  profile 指向的 store 对象。
- 单、双系统使用共享的 `.github/actions/guix-pull`。冷运行时在频道拉取成功后，
  用 `guix archive --export -r` 导出整个已编译 profile 闭包，压缩并保存到
  GitHub Actions Cache。键包含系统、架构和 `channels.scm` 哈希。
- 暖运行导入签名归档并直接调用恢复的 Guix。归档为空、导入失败或 profile
  不可用时回退到 `guix pull`。缓存仅包含归档、公钥和 profile 路径，私钥留在
  runner。Pull request 可以读取可见缓存，保存仅在非 PR 运行执行。
- 根镜像构建前单独构建 `linux-sheng` 并导出其 store 闭包。单系统、双系统
  和 EFI 共用该缓存；键由系统、架构、频道锁定和内核配方及文件内容决定。
  缓存保存早于根镜像构建，后续固件或镜像失败也可复用。

## 构建时身份

`workflow_dispatch` 输入 `desktop_username`、`desktop_password` 和
`auto_login` 写入 `images/settings.scm`（不提交），由 `images/base.scm` 读取。
本地构建没有该文件时回退为 `sheng`、自动登录。

## 产物

`scripts/build-image.sh` 调用 `guix system image -L .`，失败时打印 stderr；成功后从
实际分区表提取 ext4 分区，检查文件系统和 extlinux 配置，再转换为 Android sparse。artifact 名
`sheng-<variant>`，同时包含 U-Boot 的 `sheng-boot.img`。

## 求值先行

构建前有 `Evaluate all images` 步骤，用
`guix system image -L . --dry-run images/<variant>.scm` 逐个求值。任何未绑定变量或
服务类型错误会在实际构建前失败，避免把时间花在错误的镜像上。

手动运行时，`image=tty` 构建 TTY 根镜像，`image=none` 只构建开机镜像。

注意：镜像文件返回 `<image>` 记录，不能用 `guix system build` 求值。

## 闭包导出

`workflow_dispatch` 且 `image` 不是 `none` 时，镜像构建后自动运行
`scripts/export-closure.sh`，从 ext4 镜像的 extlinux 配置取出
`gnu.system=`，导出签名的 store 闭包和固定频道 Guix 闭包，连同公钥
打包为 `sheng-single-closures` / `sheng-dual-closures`。平板端导入和
世代切换见[离线闭包更新](offline-updates.md)。
