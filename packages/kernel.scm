;; packages/kernel.scm — Linux kernel for sheng (SM8550).
;; Port of nixos-sheng packages/kernel/default.nix at 2be57fe.
;; This is a proprietary-device port: vendor options and blobs in the config
;; are intentional.  Guix's free-software defaults are not a constraint.
(define-module (packages kernel)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages perl)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:export (linux-sheng))

(define %sheng-kernel-commit
  "87ac0f2347eb433933841e6854950dd90e96e6b2")

(define %sm8550-config
  (local-file "kernel/sm8550.config"))

(define linux-sheng
  (package
    ;; linux-libre only supplies the build machinery; the source and config
    ;; are the sheng kernel tree and debian-sheng's config.
    (inherit linux-libre)
    (name "linux-sheng")
    (version "7.3.4-sheng")
    (source
     (origin
       ;; url-fetch, not git-fetch: the pinned git builder fails in CI when
       ;; /etc/gitconfig is unreadable to the build user.
       (method url-fetch)
       (file-name (string-append "linux-sheng-" version ".tar.gz"))
       (uri (string-append
             "https://codeload.github.com/ianchb/sm8550-mainline/tar.gz/"
             %sheng-kernel-commit))
       (sha256
        (base32
         "05d6cm31a8nw863rlgi5jd26szfwvaphgdblak1ip4r3nv2dlid4"))))
    (native-inputs
     (modify-inputs (package-native-inputs linux-libre)
       (append perl)))
    (arguments
     (substitute-keyword-arguments (package-arguments linux-libre)
       ((#:phases phases '%standard-phases)
        #~(modify-phases #$phases
            (add-after 'unpack 'apply-nixos-board-changes
              (lambda _
                (invoke "sh" "-e" #$(local-file "kernel/nixos-post-patch.sh"))))
            (replace 'configure
              (lambda* (#:key make-flags #:allow-other-keys)
                (copy-file #$%sm8550-config ".config")
                (chmod ".config" #o644)
                (setenv "KCONFIG_NOTIMESTAMP" "1")
                (apply invoke "make" "olddefconfig" make-flags)
                (invoke "sh" "scripts/kconfig/merge_config.sh" "-O" "." "-m"
                        ".config" #$(local-file "kernel/nixos-extra.config"))
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
