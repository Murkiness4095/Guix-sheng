(define-module (services ucm)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu system pam)
  #:use-module (guix gexp)
  #:use-module (packages peripherals)
  #:export (sheng-ucm-service sheng-ucm-directory))

(define sheng-ucm-directory
  (directory-union "sheng-alsa-ucm2"
                   (list (file-append alsa-ucm-sheng "/share/alsa/ucm2")
                         (file-append alsa-ucm-conf "/share/alsa/ucm2"))))

(define (sheng-ucm-service)
  (simple-service 'sheng-alsa-ucm-path session-environment-service-type
                  `(("ALSA_CONFIG_UCM2" . ,sheng-ucm-directory))))
