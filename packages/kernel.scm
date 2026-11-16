;; Repackage the upstream sheng release for Guix's kernel and initrd builders.
(define-module (packages kernel)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:export (linux-sheng))

(define linux-sheng
  (package
    (name "linux-sheng")
    (version "7.3.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/ianchb/sm8550-mainline/releases/download/"
             version "/linux-xiaomi-sheng.deb"))
       (sha256
        (base32 "0h1hrm9bpv4jzn3yjq2sr7qvqr1fspjg7d9lrzmqc150z4qnjfcv"))))
    (build-system trivial-build-system)
    (supported-systems '("aarch64-linux"))
    (arguments
     (list #:modules '((guix build utils))
           #:builder
           #~(begin
               (use-modules (guix build utils))
               (setenv "PATH" #$(file-append xz "/bin"))
               (invoke #$(file-append binutils "/bin/ar")
                       "x" #$source "data.tar.xz")
               (invoke #$(file-append tar "/bin/tar") "-xf" "data.tar.xz")
               (invoke #$(file-append gzip "/bin/gzip") "-d" "boot/Image.gz")
               (mkdir-p (string-append #$output "/lib/dtbs/qcom"))
               (copy-file "boot/Image" (string-append #$output "/Image"))
               (copy-file "boot/sm8550-xiaomi-sheng.dtb"
                          (string-append #$output
                                         "/lib/dtbs/qcom/sm8550-xiaomi-sheng.dtb"))
               (copy-recursively "lib/modules"
                                 (string-append #$output "/lib/modules")))))
    (home-page "https://github.com/ianchb/sm8550-mainline")
    (synopsis "Upstream Linux kernel release for Xiaomi Pad 6S Pro")
    (description "The upstream sheng kernel binary, board device tree, and
matching kernel modules packaged for Guix.")
    (license license:gpl2)))
