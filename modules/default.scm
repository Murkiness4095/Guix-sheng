;; modules/default.scm — aggregate module list.
(define-module (sheng default)
  #:use-module (sheng boot)
  #:use-module (sheng filesystems)
  #:use-module (sheng networking)
  #:use-module (sheng hardware)
  #:export (sheng-default-services))
(define (sheng-default-services)
  (append (sheng-networking-services) (sheng-hardware-services)))
