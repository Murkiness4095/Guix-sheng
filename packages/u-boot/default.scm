;; packages/u-boot/default.scm — U-Boot for sheng with patches.
(define-module (sheng packages u-boot)
  #:use-module (gnu packages bootloaders)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:export (u-boot-sheng))
(define u-boot-sheng
  (package
    (inherit u-boot)
    (name "u-boot-sheng")
    (version "xiaomi-sheng-7025b79")
    (source (git-fetch (url "https://github.com/SushyDev/u-boot") (commit "xiaomi-sheng")))
    (synopsis "U-Boot for Xiaomi Pad 6S Pro (sheng)")))
