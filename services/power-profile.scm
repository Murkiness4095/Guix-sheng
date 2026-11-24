(define-module (services power-profile)
  #:use-module ((gnu packages freedesktop) #:select (power-profiles-daemon))
  #:use-module ((gnu packages glib) #:select (glib))
  #:use-module ((gnu packages python) #:select (python))
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:export (sheng-power-profile-service))

(define (sheng-power-profile-service)
  (simple-service
   'sheng-power-profile shepherd-root-service-type
   (list
    (shepherd-service
     (provision '(sheng-power-profile))
     (requirement '(power-profiles-daemon))
     (documentation "Apply the sheng CPU frequency limit for the power saver profile.")
     (start #~(make-forkexec-constructor
               (list #$(file-append python "/bin/python3")
                     #$(local-file "sheng-power-profile.py")
                     (string-append #$glib:bin "/bin/gdbus")
                     #$(file-append power-profiles-daemon "/bin/powerprofilesctl"))))
     (stop #~(make-kill-destructor))
     (respawn? #t)))))
