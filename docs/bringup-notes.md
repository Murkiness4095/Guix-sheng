# 启动排障笔记

记录 Guix 移植过程中的失败与证据。

## 2026-11-15 CI: git-fetch 在沙箱内读 /etc/gitconfig 失败

现象（`Build U-Boot boot.img`，run 43621470828）：

```
warning: unable to access '/etc/gitconfig': Permission denied
fatal: unknown error occurred while reading the configuration files
git-fetch: '.../git init --initial-branch=main' failed with exit code 128
```

bordeaux/ci.guix 上该 git-checkout 不存在，Software Heritage 也没有该 revision，
构建直接失败。内核和固件同样用 `git-fetch`，会撞同一问题。

处理：U-Boot、内核、固件三个源改为 `url-fetch` 的 GitHub archive tarball，
构建期不再调用 git；提交号仍写在包里，sha256 固定。已记录的 tarball 哈希：

| 包 | 提交 | base32 sha256 |
| --- | --- | --- |
| u-boot | `7025b792` | `0bcqzbixr19l4ng1i6728j1hnrhwsqb1j3fgpgh2gzybsqmnish8` |
| kernel | `52a51972` | `15g8vkw7lx0fjb5q6mhc3cj7cf31ff3lywd43hdymimjgwdv7a5i` |
| firmware | `053da477` | `1glxnlgd57bq3yrd8lv7dkdjrcbmbq7dv4n9sgaprcyc3l29gll9` |

代价：GitHub archive 由 GitHub 生成，理论上可能重新打包导致哈希变化；
出现时重算并记录。
