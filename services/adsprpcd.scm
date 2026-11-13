;; services/adsprpcd.scm — port of debian patches/adsprpcd-sensorspd.service
(define-module (services adsprpcd)
  #:use-module (gnu services)
  #:export (sheng-adsprpcd-service-type))
(define sheng-adsprpcd-service-type
  (service-type (name 'sheng-adsprpcd) (extensions '()) (default-value #f)
    (description "sensorspd aDSP RPC daemon (skeleton).")))
