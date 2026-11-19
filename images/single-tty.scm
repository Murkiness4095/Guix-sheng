;; single-tty — sheng image, tty desktop, text getty.
(load (string-append (dirname (current-filename)) "/base.scm"))
(use-modules (gnu) (gnu image) (gnu system image) (guix gexp))

(define the-os
  (sheng-os #:desktop 'tty #:root-label "userdata"))

(image
 (inherit mbr-disk-image)
 (operating-system the-os)
 (partitions
  (list (partition
         (inherit root-partition)
         (label "userdata")
         (initializer sheng-root-initializer)))))
