# sheng 桌面样板（niri + noctalia + librewolf）

登录器为 noctalia greeter，桌面为 niri，noctalia 作为 shell 启动。
需要 midnight 频道提供 noctalia 与 greeter：

```sh
guix pull -C channels.scm
guix system build system.scm
```

默认单系统（`userdata`）。双系统把根分区标签改为 `linux`。

`desktop-password-hash` 需填入 crypt 哈希，例如：

```sh
openssl passwd -6 your-password
```

把结果写进 `(password "...")`。不要提交真实密码哈希到公共仓库。

noctalia 自启：本样板把 noctalia 加入系统包，但 niri 的 `spawn-at-startup`
属于用户配置（`~/.config/niri/config.kdl`）。仓库的镜像变体通过
`/etc/sheng/niri-noctalia.kdl` 提供该配置；个人配置可按自己的习惯组织。
