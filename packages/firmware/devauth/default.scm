;; packages/firmware/devauth/default.scm — port of sheng-devauth.
(define-module (sheng packages firmware devauth)
  #:use-module (guix packages)
  #:export (sheng-devauth))
(define sheng-devauth
  (package (name "sheng-devauth") (version "1.0") (source #f)
    (build-system (gnu-build-system)) (synopsis "Keyboard auth daemon")
    (description "Port of sheng-devauth.") (home-page "https://github.com/ianchb/debian-sheng") (license #f)))
