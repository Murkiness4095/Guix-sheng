;; modules/default.scm — aggregate module list.
(define-module (modules default)
  #:use-module (modules boot)
  #:use-module (modules filesystems)
  #:use-module (modules networking)
  #:use-module (modules hardware)
  #:export (sheng-default-services))
(define (sheng-default-services)
  (append (sheng-networking-services) (sheng-hardware-services)))
