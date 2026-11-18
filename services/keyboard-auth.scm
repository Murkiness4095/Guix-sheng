(define-module (services keyboard-auth)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (packages peripherals)
  #:export (sheng-keyboard-auth-service))

(define start-qtee
  (program-file
   "start-sheng-qtee"
   #~(begin
       (let wait-for-tee ()
         (unless (file-exists? "/dev/tee0")
           (sleep 1)
           (wait-for-tee)))
       (unless (zero? (system* #$(file-append sheng-fingerprint
                                             "/libexec/fpc-sfs-config")))
         (error "QTEE secure file system configuration failed"))
       (setenv "LD_LIBRARY_PATH"
               #$(file-append sheng-fingerprint "/lib/qtee-listeners"))
       (let ((program #$(file-append sheng-fingerprint
                                    "/libexec/qteesupplicant")))
         (execl program program)))))

(define start-keyboard-auth
  (program-file
   "start-sheng-keyboard-auth"
   #~(begin
       (let wait-for-keyboard-auth ()
         (unless (and (file-exists? "/dev/nanosic_auth")
                      (file-exists? "/dev/tee0"))
           (sleep 1)
           (wait-for-keyboard-auth)))
       (let ((program #$(file-append sheng-devauth "/bin/xiaomi_devauth")))
         (execl program program)))))

(define (sheng-keyboard-auth-service)
  (simple-service
   'sheng-keyboard-auth shepherd-root-service-type
   (list
    (shepherd-service
     (provision '(sheng-qteesupplicant))
     (requirement '(udev))
     (documentation "Run the Qualcomm TEE listeners for keyboard authentication.")
     (start #~(make-forkexec-constructor (list #$start-qtee)))
     (stop #~(make-kill-destructor))
     (respawn? #t))
    (shepherd-service
     (provision '(sheng-keyboard-auth))
     (requirement '(sheng-qteesupplicant))
     (documentation "Authenticate the detachable Xiaomi keyboard.")
     (start #~(make-forkexec-constructor (list #$start-keyboard-auth)))
     (stop #~(make-kill-destructor))
     (respawn? #t)))))
