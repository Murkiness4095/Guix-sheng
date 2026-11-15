;; packages/kernel.scm — Linux kernel for sheng (SM8550).
;; Source: code002-2/sm8550-mainline (default branch sheng-7.2-rc7).
;; Config: sm8550.config from ianchb/debian-sheng master (its full config),
;; built the way debian-sheng builds it: clang/LLVM=1, then olddefconfig to
;; adapt the newer config to this tree.
;;
;; This is a proprietary-device port: vendor options and blobs in the config
;; are intentional.  Guix's free-software defaults are not a constraint.
(define-module (packages kernel)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:export (linux-sheng))

(define %sheng-kernel-commit
  "52a5197235edd2a2b6559d69b45557cf83f7d111")

(define %sm8550-config
  (local-file "kernel/sm8550.config"))

(define linux-sheng
  (package
    ;; linux-libre only supplies the build machinery; the source and config
    ;; are the sheng kernel tree and debian-sheng's config.
    (inherit linux-libre)
    (name "linux-sheng")
    (version "7.2.0-rc7")
    (source
     (origin
       ;; url-fetch, not git-fetch: the pinned git builder fails in CI when
       ;; /etc/gitconfig is unreadable to the build user.
       (method url-fetch)
       (uri (string-append
             "https://github.com/code002-2/sm8550-mainline/archive/"
             %sheng-kernel-commit ".tar.gz"))
       (sha256
        (base32
         "15g8vkw7lx0fjb5q6mhc3cj7cf31ff3lywd43hdymimjgwdv7a5i"))))
    (native-inputs
     (modify-inputs (package-native-inputs linux-libre)
       (append clang lld llvm)))
    (arguments
     (substitute-keyword-arguments (package-arguments linux-libre)
       ;; debian-sheng builds with CC=clang and LLVM=1.
       ((#:make-flags flags ''())
        #~(cons* "LLVM=1" #$flags))
       ((#:phases phases '%standard-phases)
        #~(modify-phases #$phases
            (replace 'configure
              (lambda* (#:key make-flags #:allow-other-keys)
                (copy-file #$%sm8550-config ".config")
                (chmod ".config" #o644)
                ;; Kconfig records CC_IS_CLANG and LTO options, so run it
                ;; with the same LLVM=1 flags as the build.
                (apply invoke "make" "olddefconfig" make-flags)))
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
