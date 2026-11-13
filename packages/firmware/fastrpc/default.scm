;; packages/firmware/fastrpc/default.scm — port of fastrpc/adsprpcd.
(define-module (sheng packages firmware fastrpc)
  #:use-module (guix packages)
  #:export (fastrpc-sheng))
(define fastrpc-sheng
  (package (name "fastrpc-sheng") (version "1.0") (source #f)
    (build-system (gnu-build-system)) (synopsis "FastRPC/adsprpcd for sheng")
    (description "Port of fastrpc.") (home-page "https://github.com/ianchb/debian-sheng") (license #f)))
