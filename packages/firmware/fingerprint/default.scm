;; packages/firmware/fingerprint/default.scm — port of xiaomi-sheng-fingerprint.
(define-module (sheng packages firmware fingerprint)
  #:use-module (guix packages)
  #:export (sheng-fingerprint))
(define sheng-fingerprint
  (package
    (name "sheng-fingerprint")
    (version "1.0")
    (source #f)
    (build-system (gnu-build-system))
    (synopsis "TEE-based fingerprint support for sheng")
    (description "Port of xiaomi-sheng-fingerprint (libfprint patch).")
    (home-page "https://github.com/ianchb/debian-sheng")
    (license #f)))
