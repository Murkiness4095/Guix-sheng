# 离线闭包更新与世代切换

CI 可以导出已构建系统的签名 store 闭包；平板导入后原地生成新世代，
不重刷 root 镜像，旧世代和数据保留。

刷写任何 root/sparse 镜像都会覆盖整个 ext4，`/var/guix` 和全部世代随之
丢失。闭包导入是唯一不清盘的更新方式。

## CI 产出

`build-single` / `build-dual` 的 `workflow_dispatch` 增加 `export_closures`
（默认勾选）。构建结束后上传 artifact：

- `<variant>.nar.zst`：镜像启动系统的签名闭包
- `guix-<store>.nar.zst`：固定频道 `guix pull` 的 Guix 闭包
- `signing-key.pub`、`SHA256SUMS`

签名由 CI 的 guix-daemon 密钥完成；`guix archive --import` 强制验签。
要让平板只授权一次，在仓库 Secrets 配置固定的
`GUIX_ARCHIVE_SIGNING_KEY` / `GUIX_ARCHIVE_SIGNING_KEY_PUB`。未配置时
每个 runner 生成新密钥，公钥随之变化，平板需重新授权。

## 平板端

```sh
sudo guix archive --authorize < signing-key.pub     # 每次更换 CI 密钥后一次
zstd -dc sheng-tty.nar.zst | sudo guix archive --import
zstd -dc guix-*.nar.zst | sudo guix archive --import
```

分片下载时先拼接：`cat part* | zstd -dc | sudo guix archive --import`。

生成新世代必须使用与 CI 相同的 `channels.scm` 和仓库提交，否则 store
path 不同，缺失的包会本地编译：

```sh
sudo -i guix time-machine -C channels.scm -- \
     system reconfigure -L . /path/to/system.scm
```

闭包已导入时这一步不编译内核和包，只求值、激活并重写
`/boot/extlinux/extlinux.conf`，随后重启。

## 世代管理

```sh
guix system list-generations
guix system switch-generation 3     # re-installs bootloader, keeps all generations
guix system roll-back
guix system delete-generations
```

旧世代是 GC root，`guix gc` 不会回收；只有删除世代才释放磁盘。

## 限制

- 启动菜单目前是 `PROMPT 0`，会自动启动默认世代；开机选世代需要把
  `modules/sheng-bootloader.scm` 的 `PROMPT` 改成 `1`，在串口下输入
  `guix-gen-N`。否则只能在系统内切换。
- `desktop`、`vendor_services` 与 CI 不同时会引入闭包外的包，需本地编译。
- 每代钉住一份闭包，先确认根分区空间。
- 更换 `channels.scm` 会使全部 store path 失效，需同时导入新的 Guix 闭包。
- 只有 U-Boot / 分区布局变化才需要重刷 `sheng-boot.img`。
