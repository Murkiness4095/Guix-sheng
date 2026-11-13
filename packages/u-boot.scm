;; packages/u-boot/default.scm — U-Boot for sheng (SM8550).
;; Source: SushyDev/u-boot branch xiaomi-sheng.  Defconfig: sm8550_defconfig.
;; Cross-compiled for aarch64; the board boot uses this to produce boot.img.
(define-module (packages u-boot)
  #:use-module (gnu packages bootloaders)
  #:use-module (gnu packages android)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages zig)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:export (u-boot-sheng))

(define u-boot-sheng-source
  (package
    (inherit u-boot)
    (name "u-boot-sheng-source")
    (version "xiaomi-sheng")
    (source (git-fetch
              (url "https://github.com/SushyDev/u-boot")
              (commit "7025b792e2884c5fb4747d891e30002ea029048a")
              (sha256
               (base32
                "0rzcvchj9npzpdvrw8xz3jff426aqwdhjsjfkzk2nhikfyfx0m33"))
              (patches
               (list (local-file "u-boot/patches/prefer-abl-memory-layout.patch")
                     (local-file "u-boot/patches/fix-fastboot-menu-reboot-mode.patch")))))))

(define u-boot-sheng
  (let ((base (make-u-boot-package "sm8550" "aarch64-linux-gnu"
                                   #:u-boot u-boot-sheng-source)))
    (package
      (inherit base)
      (name "u-boot-sheng")
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append zig-0.15 xxd android-tools)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:make-flags flags ''())
          #~(cons* "ZIG=zig"
                   "HOME=/tmp"
                   #$flags))
         ((#:phases phases '%standard-phases)
          #~(modify-phases #$phases
              (add-after 'install 'install-sheng-files
                (lambda* (#:key outputs #:allow-other-keys)
                  (let ((out (assoc-ref outputs "out")))
                    (for-each (lambda (f)
                                (when (file-exists? f)
                                  (install-file f out)))
                              '("u-boot.bin" "u-boot-nodtb.bin"
                                "u-boot-dtb.bin" "u-boot.dtb")))))))))
      (synopsis "U-Boot for Xiaomi Pad 6S Pro (sheng, SM8550)")
      (description
       "U-Boot built for the sheng board with the xiaomi-sheng fork and
the sm8550_defconfig.  Producing the Android boot.img wrapper is left to
the image step; this package installs the raw U-Boot binaries."))))
