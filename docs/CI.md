# CI 设计

## 工作流

- `build-single`：单系统五种镜像（tty/kde/gnome/niri/noctalia）
- `build-dual`：双系统五种镜像
- 每条工作流是**单个 job**：先 `guix pull -C channels.scm` 一次，再循环构建
  所有变体，避免每个镜像重复拉取/编译 Guix。
- 触发路径：`images/**`、`scripts/**`、`channels.scm`、对应 workflow 文件。
- `pull-test`：仅用于验证频道拉取耗时，稳定后删除。

## 频道

`channels.scm` 固定提交：

- `guix`：`codeberg.org/guix/guix.git`（Savannah 在 CI 报
  `SSL error: syscall failure`），提交 `3c50593f...`（含 niri）。
- `midnight`：`codeberg.org/stampede/midnight.git`（noctalia、noctalia-greeter）。

固定提交可复现；若该提交没有现成 substitute，`guix pull` 会本地编译 Guix。

## 构建时身份

`workflow_dispatch` 输入 `desktop_username`、`desktop_password` 写入
`images/settings.scm`（不提交），由 `images/base.scm` 读取并用于桌面用户。
本地构建没有该文件时回退为 `sheng`。

## 产物

`scripts/build-image.sh` 调用 `guix system image`，从 1 MiB 偏移提取 root
分区为 ext4，并尽可能转换为 Android sparse。artifact 名 `sheng-<variant>`。

## 缓存

Guix 没有 `cache-nix-action` 的等价物，使用原生替代机制：

- 上游包：默认 substitute（`ci.guix.gnu.org` / `bordeaux`）。
- `guix pull` 的 Guix profile：`guix archive --export -r` 导出 nar，
  由 `actions/cache` 以 `channels.scm` 哈希为 key 跨运行复用；命中后先
  `guix archive --import`，`guix pull` 无需重新编译 Guix。
- `~/.cache/guix`（Git checkout 与包缓存）一并缓存。
- 镜像本身（ext4/sparse）体积大，不放入 actions/cache（仓库 10 GB 上限）；
  它们的昂贵部分是系统闭包，仍由官方 substitute 覆盖大部分上游包。

`guix publish --cache` 也可以做远程二进制缓存，但需要持久存储；本仓库未配置。
