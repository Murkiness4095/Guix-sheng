;; packages/firmware/default.scm — sheng vendor firmware blobs.
;; Installed under /lib/firmware; source: ianchb/sheng-firmware.
(define-module (packages firmware)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:export (sheng-firmware))

(define sheng-firmware
  (package
    (name "sheng-firmware")
    (version "1.0")
    (source (git-fetch
              (url "https://github.com/ianchb/sheng-firmware")
              (commit "053da477a5c338ac28d7c1c869e8c3ff7ca24d11")
              (sha256
               (base32
                "0hgz4s6gspdld0yncxpbs4qish13n2qa686k5a875xr8dcq15api"))))
    (build-system copy-build-system)
    (arguments
     (list #:install-plan #~'(("." "lib/firmware"))))
    (synopsis "Firmware blobs for Xiaomi Pad 6S Pro (sheng)")
    (description "Vendor firmware for sm8550 peripherals: ath12k WLAN,
Cirrus CS35L43 speaker DSP, Novatek touch, fingerprint TA and others.")
    (home-page "https://github.com/ianchb/sheng-firmware")
    (license #f)))
