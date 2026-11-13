;; packages/firmware/pen/default.scm — port of xiaomi-pen-status.
(define-module (sheng packages firmware pen)
  #:use-module (guix packages)
  #:export (sheng-pen-status))
(define sheng-pen-status
  (package (name "sheng-pen-status") (version "1.0") (source #f)
    (build-system (gnu-build-system)) (synopsis "Stylus status/battery")
    (description "Port of xiaomi-pen-status.")
    (home-page "https://github.com/ianchb/debian-sheng") (license #f)))
