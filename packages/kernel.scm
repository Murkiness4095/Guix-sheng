;; packages/kernel.scm — Linux kernel for sheng (SM8550).
;; Source: ianchb/sm8550-mainline, branch sheng-7.3.0.
;; Config: sm8550.config from debian-sheng.
(define-module (packages kernel)
  #:use-module (gnu packages linux)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:export (linux-sheng))

(define %sm8550-mainline-commit
  "1fb56e66091e71160d7c7f8e13b065d5b6ab8b8c")

(define linux-sheng
  (package
    (inherit
     (customize-linux
      #:name "linux-sheng"
      #:source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/ianchb/sm8550-mainline")
              (commit %sm8550-mainline-commit)))
        (sha256
         (base32
          "0476xzvyavi17jl9r3km3qnf5ilf2rcsadhdz5cas2psy9hsrk24")))
      #:defconfig (local-file "kernel/sm8550.config")
      #:extra-version "sheng"))
    ;; The source is 7.3.0, not whatever linux-libre is at.
    (version "7.3.0")))
