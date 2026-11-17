(define-module (services thp)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (packages peripherals)
  #:export (sheng-thp-service))

(define start-thp
  (program-file
   "start-sheng-thp"
   #~(begin
       (unless (file-exists? "/run/xiaomi-sheng-thp")
         (mkdir "/run/xiaomi-sheng-thp" #o755))
       ;; The input driver can publish these nodes after Shepherd starts.
       (let wait-for-touch-device ()
         (unless (and (file-exists? "/proc/nvt_thp_stream")
                      (file-exists? "/proc/nvt_thp_stylus"))
           (sleep 1)
           (wait-for-touch-device)))
       (let ((program #$(file-append sheng-thp
                                      "/libexec/xiaomi-sheng-thp/xiaomi-sheng-thp")))
         (execl program program)))))

(define (sheng-thp-service)
  (simple-service
   'sheng-thp shepherd-root-service-type
   (list
    (shepherd-service
     (provision '(sheng-thp))
     (requirement '(udev))
     (documentation "Process sheng NT36532E touch and stylus input.")
     (start #~(make-forkexec-constructor (list #$start-thp)))
     (stop #~(make-kill-destructor SIGINT))
     (respawn? #t)))))
