;; packages/firmware/alsa-ucm/default.scm — ALSA UCM for sheng (port of debian alsa-xiaomi-sheng).
(define-module (sheng packages firmware alsa-ucm)
  #:use-module (guix packages)
  #:export (alsa-ucm-sheng))
(define alsa-ucm-sheng
  (package
    (name "alsa-ucm-sheng")
    (version "1.0")
    (source #f)
    (build-system (gnu-build-system))
    (synopsis "ALSA UCM config for Xiaomi Pad 6S Pro")
    (description "Port of debian-sheng alsa-xiaomi-sheng.")
    (home-page "https://github.com/ianchb/debian-sheng")
    (license #f)))
