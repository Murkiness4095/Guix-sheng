;; dual-kde — sheng image, kde desktop, SDDM, librewolf.
(load (string-append (dirname (current-filename)) "/base.scm"))
(use-modules (gnu) (gnu image) (gnu system image) (guix gexp))

(define the-os
  (sheng-os #:desktop 'kde #:root-label "linux"))

(image
 (inherit mbr-disk-image)
 (operating-system the-os)
 (partitions
  (list (partition
         (inherit root-partition)
         (label "linux")
         (initializer sheng-root-initializer)))))
