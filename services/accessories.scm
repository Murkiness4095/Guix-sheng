(define-module (services accessories)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (packages peripherals)
  #:export (sheng-keyboard-angle-service
            sheng-mipps-service
            sheng-pen-autostart-service))

(define (sheng-keyboard-angle-service)
  (simple-service
   'sheng-keyboard-angle shepherd-root-service-type
   (list
    (shepherd-service
     (provision '(sheng-keyboard-angle))
     (requirement '(udev sheng-adsprpcd))
     (documentation "Apply sheng keyboard fold-angle policy.")
     (start #~(make-forkexec-constructor
               (list #$(file-append sheng-keyboard-helper
                                    "/libexec/xiaomi-sheng-keyboard-helper")
                     "--angle")))
     (stop #~(make-kill-destructor))
     (respawn? #t)))))

(define (sheng-mipps-service)
  (udev-rules-service 'sheng-mipps sheng-mipps-auth))

(define (sheng-pen-autostart-service)
  (simple-service
   'sheng-pen-autostart etc-service-type
   (list
    (list "xdg/autostart/xiaomi-pen-status.desktop"
          (file-append sheng-pen-status
                       "/etc/xdg/autostart/xiaomi-pen-status.desktop")))))
