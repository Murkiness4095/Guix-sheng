;; services/wlan.scm — port of debian patches/sheng-wlan.service
(define-module (sheng services wlan)
  #:use-module (gnu services)
  #:export (sheng-wlan-service-type))
(define sheng-wlan-service-type
  (service-type (name 'sheng-wlan) (extensions '()) (default-value #f)
    (description "Load Sheng WLAN with original MAC (skeleton).")))
