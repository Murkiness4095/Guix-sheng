;; packages/u-boot.scm — U-Boot for sheng (SM8550) plus the Android boot.img
;; that ABL loads.  Source: SushyDev/u-boot branch xiaomi-sheng.
;;
;; Mirrors nixos-sheng/packages/u-boot/default.nix: same fork, same board
;; patches, same mkbootimg arguments (taken from the stock boot.img header).
(define-module (packages u-boot)
  #:use-module (gnu packages bootloaders)
  #:use-module (gnu packages python)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages zig)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:export (u-boot-sheng
            u-boot-sheng-dual))

(define %u-boot-sheng-commit
  "7025b792e2884c5fb4747d891e30002ea029048a")

;; (gnu packages bootloaders) does not export its 'u-boot' package; only
;; 'make-u-boot-package', which takes it as the default base.  Reach the
;; binding the same way the module itself does, so the fork keeps every
;; input and phase upstream maintains.
(define %u-boot-base
  (@@ (gnu packages bootloaders) u-boot))

(define u-boot-sheng-source
  (package
    (inherit %u-boot-base)
    (name "u-boot-sheng-source")
    (version "xiaomi-sheng")
    (source
     (origin
       ;; url-fetch, not git-fetch: the pinned git builder fails in CI when
       ;; /etc/gitconfig is unreadable to the build user.
       (method url-fetch)
       (uri (string-append
             "https://github.com/SushyDev/u-boot/archive/"
             %u-boot-sheng-commit ".tar.gz"))
       (sha256
        (base32
         "0bcqzbixr19l4ng1i6728j1hnrhwsqb1j3fgpgh2gzybsqmnish8"))
       (patches
        (list (local-file "u-boot/patches/prefer-abl-memory-layout.patch")
              (local-file "u-boot/patches/fix-fastboot-menu-reboot-mode.patch")
              (local-file "u-boot/patches/deduplicate-sm8550-clock-config.patch")))))))

(define* (make-u-boot-sheng #:key (root-label "userdata"))
  "Return U-Boot for sheng, with a boot.img whose cmdline roots at ROOT-LABEL.
ROOT-LABEL is also written into the fork's default environment by the
dual-system variant below."
  (let* ((base (make-u-boot-package "sm8550" "aarch64-linux-gnu"
                                    #:u-boot u-boot-sheng-source))
         (cmdline (string-append
                   "console=ttyMSM0,115200n8 console=ttyGS0,115200n8 "
                   "g_serial.use_acm=1 root=PARTLABEL=" root-label)))
    (package
      (inherit base)
      (name (if (string=? root-label "userdata")
                "u-boot-sheng"
                "u-boot-sheng-dual"))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append zig-0.15 xxd python-wrapper)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ;; U-Boot's test suite does not exercise this board.
         ((#:tests? _ #t) #f)
         ((#:make-flags flags ''())
          #~(cons* "ZIG=zig" #$flags))
         ((#:phases phases '%standard-phases)
          #~(modify-phases #$phases
              #$@(if (string=? root-label "userdata")
                     '()
                     (list
                      #~(add-after 'unpack 'patch-root-partition
                          (lambda _
                            ;; The fork's default environment hardcodes
                            ;; userdata in the sysboot, rescue and menu paths.
                            (substitute* "board/qualcomm/sheng.env"
                              (("part number scsi 0 userdata partnum")
                               (string-append "part number scsi 0 "
                                              #$root-label " partnum"))
                              (("root=PARTLABEL=userdata")
                               (string-append "root=PARTLABEL="
                                              #$root-label)))))))
              (add-before 'build 'set-zig-environment
                (lambda _
                  ;; zig writes caches relative to $HOME, which Guix does not
                  ;; provide as a writable directory.
                  (let ((tmp (or (getenv "TMPDIR") "/tmp")))
                    (setenv "HOME" tmp)
                    (setenv "ZIG_GLOBAL_CACHE_DIR"
                            (string-append tmp "/zig-cache"))
                    (setenv "ZIG_LOCAL_CACHE_DIR"
                            (string-append tmp "/zig-cache")))))
              (add-after 'install 'build-boot-image
                (lambda* (#:key outputs #:allow-other-keys)
                  (let* ((out (assoc-ref outputs "out"))
                         (libexec (string-append out "/libexec")))
                    (invoke "python" #$(local-file "mkbootimg-v2.py")
                            "--kernel" (string-append libexec "/u-boot-dtb.bin")
                            "--dtb" (string-append libexec "/u-boot.dtb")
                            "--cmdline" #$cmdline
                            "--base" "0x00000000"
                            "--kernel_offset" "0x00008000"
                            "--tags_offset" "0x01e00000"
                            "--pagesize" "4096"
                            "-o" (string-append out "/boot.img")))))))))
      (synopsis "U-Boot for Xiaomi Pad 6S Pro (sheng, SM8550)")
      (description
       "U-Boot built for the sheng board from the xiaomi-sheng fork with
sm8550_defconfig.  Also installs boot.img, the Android boot image ABL loads,
whose cmdline selects the root filesystem by PARTLABEL."))))

(define u-boot-sheng
  (make-u-boot-sheng))

(define u-boot-sheng-dual
  (make-u-boot-sheng #:root-label "linux"))
