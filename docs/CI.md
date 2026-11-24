# CI、固定频道与缓存

`build-single` 对应 `userdata`，`build-dual` 对应 `linux`。两条工作流均使用 ARM64 runner。自动运行求值四种镜像声明并构建 TTY 系统闭包。单系统工作流另外检查个人配置样板和外设包，双系统工作流验证自身配置。手动运行默认 `image=none`，只导出 TTY 更新闭包。显式选择镜像时，先构建该系统闭包，再封装可刷 rootfs。自动运行和手动运行使用不同并发组。

`channels.scm` 固定 Guix 和 midnight。缓存分别保存已编译的 Guix profile、板级内核和系统 store 闭包。系统闭包的精确键按架构、变体、布局和源码区分。精确键未命中时，依次尝试同布局旧缓存、另一布局的同变体缓存、旧版共享缓存。Guix 按当前声明计算 store 路径并复用匹配的项。系统闭包已构建成功而镜像封装失败时，仍可保存已完成的闭包缓存。

CI 将登录账号、密码哈希、自动登录和外设开关写入临时 `images/settings.scm`。手动输入的初始密码会出现在运行元数据中。本地构建无该文件时使用 `images/base.scm` 的默认值。

| 产物 | 内容 |
| --- | --- |
| `sheng-single-closures` / `sheng-dual-closures` | 系统路径、签名系统及 Guix profile 归档、公钥、校验和 |
| `sheng-single-images` / `sheng-dual-images` | 手动镜像构建的开机镜像与 sparse rootfs |
| `sheng-*-system-build-diagnostics` | 系统闭包失败时的诊断日志 |

镜像脚本从分区表定位 ext4，检查启动配置并完成 store 数据库注册，再生成 Android sparse 镜像。失败时先定位第一个失败步骤。若系统闭包通过，再检查镜像封装和上传结果。平板端见[闭包更新与回退](offline-updates.md)。
