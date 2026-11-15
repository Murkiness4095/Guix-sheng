;; packages/firmware.scm — sheng vendor firmware blobs.
;; Installed under /lib/firmware; source: ianchb/sheng-firmware.
(define-module (packages firmware)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:export (sheng-firmware))

(define sheng-firmware
  (package
    (name "sheng-firmware")
    (version "1.0")
    (source
     (origin
       ;; url-fetch, not git-fetch: the pinned git builder fails in CI when
       ;; /etc/gitconfig is unreadable to the build user.
       (method url-fetch)
       (uri (string-append
             "https://github.com/ianchb/sheng-firmware/archive/"
             "053da477a5c338ac28d7c1c869e8c3ff7ca24d11.tar.gz"))
       (sha256
        (base32
         "1glxnlgd57bq3yrd8lv7dkdjrcbmbq7dv4n9sgaprcyc3l29gll9"))))
    (build-system copy-build-system)
    (arguments
     (list #:install-plan #~'(("." "lib/firmware"))))
    (synopsis "Firmware blobs for Xiaomi Pad 6S Pro (sheng)")
    (description "Vendor firmware for sm8550 peripherals: ath12k WLAN,
Cirrus CS35L43 speaker DSP, Novatek touch, fingerprint TA and others.")
    (home-page "https://github.com/ianchb/sheng-firmware")
    (license #f)))
