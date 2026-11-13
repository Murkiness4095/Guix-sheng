;; packages/firmware/keyboard/default.scm — port of xiaomi-sheng-keyboard-helper.
(define-module (sheng packages firmware keyboard)
  #:use-module (guix packages)
  #:export (sheng-keyboard-helper))
(define sheng-keyboard-helper
  (package (name "sheng-keyboard-helper") (version "1.0") (source #f)
    (build-system (gnu-build-system)) (synopsis "Keyboard micmute/angle helper")
    (description "Port of xiaomi-sheng-keyboard-helper.")
    (home-page "https://github.com/ianchb/debian-sheng") (license #f)))
