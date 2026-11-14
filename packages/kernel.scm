;; packages/kernel.scm — Linux kernel for sheng (SM8550).
;; Source: ianchb/sm8550-mainline, branch sheng-7.3.0.
;; Config: sm8550.config from debian-sheng.
;;
;; The config is Debian's full .config, not a minimal defconfig.  Passing it
;; to customize-linux would make its verify-config phase compare GCC-computed
;; symbols (CC_IS_CLANG, LTO_CLANG, ...) with the clang values in the file and
;; fail, so load it directly with olddefconfig instead.
(define-module (packages kernel)
  #:use-module (gnu packages linux)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:export (linux-sheng))

(define %sm8550-mainline-commit
  "1fb56e66091e71160d7c7f8e13b065d5b6ab8b8c")

(define %sm8550-config
  (local-file "kernel/sm8550.config"))

(define linux-sheng
  (package
    (inherit linux-libre)
    (name "linux-sheng")
    ;; The source is 7.3.0, not whatever linux-libre is at.
    (version "7.3.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ianchb/sm8550-mainline")
             (commit %sm8550-mainline-commit)))
       (sha256
        (base32
         "0476xzvyavi17jl9r3km3qnf5ilf2rcsadhdz5cas2psy9hsrk24"))))
    (arguments
     (substitute-keyword-arguments (package-arguments linux-libre)
       ((#:phases phases '%standard-phases)
        #~(modify-phases #$phases
            (replace 'configure
              (lambda _
                (setenv "EXTRAVERSION" "-sheng")
                (copy-file #$%sm8550-config ".config")
                (chmod ".config" #o644)
                (invoke "make" "olddefconfig")))
            ;; arm64's 'all' target builds Image only; Guix's install phase
            ;; copies whichever .dtb files exist, so build them first.
            (add-after 'build 'build-dtbs
              (lambda* (#:key make-flags parallel-build?
                        #:allow-other-keys)
                (apply invoke "make" "dtbs"
                       (append make-flags
                               (list "-j"
                                     (if parallel-build?
                                         (number->string
                                          (parallel-job-count))
                                         "1"))))))))))))
