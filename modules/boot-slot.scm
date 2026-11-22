(define-module (modules boot-slot)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (packages qbootctl)
  #:export (sheng-boot-slot))

(define (sheng-boot-slot)
  (simple-service
   'sheng-boot-slot shepherd-root-service-type
   (list (shepherd-service
          (provision '(sheng-boot-slot))
          (requirement '(user-processes udev))
          (documentation "Mark the running Qualcomm A/B boot slot successful.")
          (one-shot? #t)
          (start #~(lambda ()
                     (if (and (file-exists? "/dev/disk/by-partlabel/boot_a")
                              (file-exists? "/dev/disk/by-partlabel/boot_b"))
                         (zero? (system* #$(file-append qbootctl "/bin/qbootctl") "-m"))
                         #t)))))))
