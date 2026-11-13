;; packages/firmware/charger/default.scm — port of xiaomi-mipps-auth / xiaomi-charger-mode.
(define-module (sheng packages firmware charger)
  #:use-module (guix packages)
  #:export (sheng-mipps-auth sheng-charger-mode))
(define sheng-mipps-auth
  (package (name "sheng-mipps-auth") (version "1.0") (source #f)
    (build-system (gnu-build-system)) (synopsis "MIPPS fast-charge auth")
    (description "Port of xiaomi-mipps-auth.") (home-page "https://github.com/ianchb/debian-sheng") (license #f)))
(define sheng-charger-mode
  (package (name "sheng-charger-mode") (version "1.0") (source #f)
    (build-system (gnu-build-system)) (synopsis "Charger mode screen")
    (description "Port of xiaomi-charger-mode.") (home-page "https://github.com/ianchb/debian-sheng") (license #f)))
