;; packages/firmware/libssc/default.scm — port of libssc with wait patch.
(define-module (sheng packages firmware libssc)
  #:use-module (guix packages)
  #:export (libssc-sheng))
(define libssc-sheng
  (package (name "libssc-sheng") (version "0.4.4") (source #f)
    (build-system (gnu-build-system)) (synopsis "libssc client for sheng")
    (description "Port of libssc with wait_for_qmi_service patch.")
    (home-page "https://github.com/ianchb/debian-sheng") (license #f)))
