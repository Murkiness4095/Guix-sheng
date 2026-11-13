;; packages/firmware/default.scm — sheng firmware from sheng-firmware repo.
(define-module (sheng packages firmware)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:export (firmware-sheng))

(define firmware-sheng
  (package
    (name "firmware-sheng")
    (version "1.0")
    (source (git-fetch
              (url "https://github.com/ianchb/sheng-firmware")
              (commit "master")))
    (build-system (gnu-build-system))
    (synopsis "Firmware blobs for sheng")
    (description "Vendor firmware for sm8550 peripherals.")
    (home-page "https://github.com/ianchb/sheng-firmware")
    (license #f)))
