;; packages/firmware/thp/default.scm — port of xiaomi-sheng-thp.
(define-module (sheng packages firmware thp)
  #:use-module (guix packages)
  #:export (sheng-thp))
(define sheng-thp
  (package
    (name "sheng-thp")
    (version "0.3.9")
    (source #f)
    (build-system (gnu-build-system))
    (synopsis "Touch/stylus processing for sheng")
    (description "Port of xiaomi-sheng-thp.")
    (home-page "https://github.com/ianchb/debian-sheng")
    (license #f)))
