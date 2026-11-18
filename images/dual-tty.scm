;; dual-tty — sheng image, tty desktop, text getty, librewolf.
(load (string-append (dirname (current-filename)) "/base.scm"))
(use-modules (gnu) (gnu image) (gnu system image) (guix gexp))

(define the-os
  (sheng-os #:desktop 'tty #:root-label "linux"))

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
                             (list #:wal-mode? #f)))))))))
