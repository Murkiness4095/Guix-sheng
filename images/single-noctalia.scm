;; images/single-noctalia.scm — sheng single system, noctalia desktop, noctalia greeter, librewolf.
(load (string-append (dirname (current-filename)) "/base.scm"))
(use-modules (gnu) (gnu image) (gnu system image) (guix gexp))

(define the-os
  (sheng-os #:desktop 'noctalia #:hostname "sheng" #:root-label "linux"))

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
