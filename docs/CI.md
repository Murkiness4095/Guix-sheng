# CI 设计

## 工作流

- `build-single`：单系统五种镜像（tty/kde/gnome/niri/noctalia）
- `build-dual`：双系统五种镜像
- 每条工作流是**单个 job**：`guix pull -C channels.scm` 一次，再循环构建所有
  变体，避免每个镜像重复拉取/编译 Guix。
- 触发路径：`images/**`、`scripts/**`、`channels.scm`、对应 workflow 文件。

## 频道

`channels.scm` 固定提交：

- `guix`：`codeberg.org/guix/guix.git`（Savannah 在 CI 报
  `SSL error: syscall failure`），提交 `3c50593f...`（含 niri）。
- `midnight`：`codeberg.org/stampede/midnight.git`（noctalia、noctalia-greeter）。

固定提交可复现；若该提交没有现成 substitute，`guix pull` 会本地编译 Guix。

## 缓存

Guix 没有 `cache-nix-action` 的等价物：

- 上游包：默认 substitute（`ci.guix.gnu.org` / `bordeaux`）。
- `~/.cache/guix`（Git checkout 与包缓存）由 `actions/cache` 复用，省去重复克隆。
- 不缓存 Guix profile 的 store 闭包：`guix archive --export` 默认签名，密钥默认
  在 `/etc/guix`，非 root 无法使用，且跨运行无法稳定复用签名。镜像本身体积也
  超过仓库 10 GB 缓存上限。
- `guix publish --cache` 可做远程二进制缓存，但需要持久存储；本仓库未配置。

因此首次运行的 `guix pull` 约 30 分钟，这是当前主要固定成本。

## 构建时身份

`workflow_dispatch` 输入 `desktop_username`、`desktop_password` 写入
`images/settings.scm`（不提交），由 `images/base.scm` 读取并用于桌面用户。
本地构建没有该文件时回退为 `sheng`。

## 产物

`scripts/build-image.sh` 调用 `guix system image`，失败时打印 stderr；成功后从
1 MiB 偏移提取 root 分区为 ext4，并尽可能转换为 Android sparse。artifact 名
`sheng-<variant>`。
