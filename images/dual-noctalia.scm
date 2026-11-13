;; images/dual-noctalia.scm — sheng dual system, noctalia desktop, noctalia greeter, librewolf.
(load "images/base.scm")
(use-modules (gnu) (gnu image) (gnu system image) (guix gexp))

(define the-os
  (sheng-os #:desktop 'noctalia #:hostname "sheng-dual" #:root-label "linux"))

(image
 (inherit mbr-disk-image)
 (operating-system the-os)
 (partitions
  (list (partition
         (inherit root-partition)
         (label "linux")
         (initializer
          #~(lambda (root . args)
              (apply (@ (gnu build image) initialize-root-partition)
                     root
                     (append args
                             (list #:register-closures? #f
                                   #:wal-mode? #f)))))))))
