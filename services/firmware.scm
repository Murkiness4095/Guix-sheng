;; services/firmware.scm — vendor firmware/userspace stack (Guix port of nixos-sheng modules/firmware.nix)
(define-module (services firmware)
  #:use-module (gnu services)
  #:export (sheng-firmware-service-type))

;; TODO: translate systemd units to shepherd services:
;; adsprpcd-sensorspd, iio-sensor-proxy, sheng-devauth, qteesupplicant,
;; sfsconfig, xiaomi-sheng-thp, xiaomi-mipps-auth, xiaomi-charger-mode,
;; sheng-sensors-data, keyboard helpers, pen status, fprintd env.
(define sheng-firmware-service-type
  (service-type
    (name 'sheng-firmware)
    (extensions '())
    (default-value #f)
    (description "Xiaomi sheng vendor userspace stack (skeleton).")))
