;; images/single-noctalia.scm — sheng single system, noctalia desktop, noctalia greeter, librewolf.
(load "images/base.scm")
(use-modules (gnu) (gnu image) (gnu system image) (guix gexp))

(define the-os
  (sheng-os #:desktop 'noctalia #:hostname "sheng" #:root-label "userdata"))

(image
 (inherit mbr-disk-image)
 (operating-system the-os)
 (partitions
  (list (partition
         (inherit root-partition)
         (label "userdata")
         (initializer
          #~(lambda (root . args)
              (apply (@ (gnu build image) initialize-root-partition)
                     root
                     (append args
                             (list #:register-closures? #f
                                   #:wal-mode? #f)))))))))
