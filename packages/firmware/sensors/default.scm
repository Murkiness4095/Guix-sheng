;; packages/firmware/sensors/default.scm — port of sheng-sensors + iio-sensor-proxy.
(define-module (sheng packages firmware sensors)
  #:use-module (guix packages)
  #:export (sheng-sensors iio-sensor-proxy-sheng))
(define sheng-sensors
  (package (name "sheng-sensors") (version "1.0") (source #f)
    (build-system (gnu-build-system)) (synopsis "SSC sensor registry")
    (description "Port of sheng-sensors.") (home-page "https://github.com/ianchb/debian-sheng") (license #f)))
(define iio-sensor-proxy-sheng
  (package (name "iio-sensor-proxy-sheng") (version "3.9") (source #f)
    (build-system (gnu-build-system)) (synopsis "IIO sensor proxy for sheng")
    (description "Port of iio-sensor-proxy.") (home-page "https://github.com/ianchb/debian-sheng") (license #f)))
