;; packages/kernel/default.scm — sheng kernel from sm8550-mainline.
(define-module (sheng packages kernel)
  #:use-module (gnu packages linux)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:export (linux-sheng))

(define linux-sheng
  (package
    (inherit linux-libre)
    (name "linux-sheng")
    (version "7.3.0")
    (source (git-fetch
              (url "https://github.com/ianchb/sm8550-mainline")
              (commit "sheng-7.3.0")))
    (synopsis "Linux kernel for Xiaomi Pad 6S Pro (sheng)")
    (description "Mainline sm8550 kernel; config sm8550.config.")))
