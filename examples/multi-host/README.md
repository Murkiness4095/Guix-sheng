# 多机部署样板

Guix 没有 flake-parts；对应的机制是 `guix deploy`。`deploy.scm` 返回
`<machine>` 列表，每台机器指向一个 `<operating-system>`。

```sh
guix pull -C channels.scm
guix deploy deploy.scm
```

部署只更新正在运行的系统，不会重新刷写 U-Boot。多机共享同一份板级声明时，
把公共部分抽成模块，各主机只覆盖主机名、用户和根分区标签；不要复制整份配置。
