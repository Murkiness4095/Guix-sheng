(define-module (services serial-console)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:export (sheng-serial-console))

(define (sheng-serial-console)
  (simple-service
   'sheng-serial-console shepherd-root-service-type
   (list (shepherd-service
          (provision '(sheng-serial-console))
          (requirement '(user-processes udev))
          (documentation "Provide a login prompt on the USB serial gadget.")
          (start #~(make-forkexec-constructor
                    (list #$(file-append util-linux "/sbin/agetty")
                          "--login-program" "/run/current-system/profile/bin/login"
                          "--local-line" "ttyGS0" "115200" "vt102")))
          (stop #~(make-kill-destructor))
          (respawn? #t)))))
