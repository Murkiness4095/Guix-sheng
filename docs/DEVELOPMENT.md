# 开发指南

- 本地求值：`guix system build images/single-tty.scm`
- 生成镜像并提取根分区：`scripts/build-image.sh images/single-tty.scm`
- 需要 niri/noctalia 的变体先 `guix pull -C channels.scm`
- CI：`build-single` / `build-dual`，ARM runner；手动输入只有 `image` 和
  `vendor_services`
- 不要提交 `images/settings.scm`（CI 生成）
