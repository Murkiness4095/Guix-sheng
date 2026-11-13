;; packages/firmware/blobs/default.scm — port of sheng-firmware-blobs.
(define-module (sheng packages firmware blobs)
  #:use-module (guix packages)
  #:export (sheng-firmware-blobs))
(define sheng-firmware-blobs
  (package (name "sheng-firmware-blobs") (version "1.0") (source #f)
    (build-system (gnu-build-system)) (synopsis "Firmware blobs for sheng")
    (description "Port of sheng-firmware-blobs.") (home-page "https://github.com/Murkiness4095/nixos-sheng") (license #f)))
