(define-module (services audio)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (services ucm)
  #:export (sheng-audio-services))

(define start-hifi
  (program-file
   "start-sheng-hifi"
   #~(begin
       (let wait-for-card ()
         (unless (file-exists? "/dev/snd/controlC0")
           (sleep 1)
           (wait-for-card)))
       (setenv "ALSA_CONFIG_UCM2" #$sheng-ucm-directory)
       (let ((program #$(file-append alsa-utils "/bin/alsaucm")))
         (execl program program "-c" "Xiaomi-Pad6SPro"
                "set" "_verb" "HiFi" "set" "_enadev" "Speaker"
                "set" "_enadev" "Mic3")))))

(define (sheng-audio-services)
  (list
   (sheng-ucm-service)
   (simple-service
    'sheng-hifi shepherd-root-service-type
    (list (shepherd-service
           (provision '(sheng-hifi))
           (requirement '(udev))
           (documentation "Initialize sheng speakers and microphones with ALSA UCM.")
           (start #~(make-forkexec-constructor (list #$start-hifi)))
           (stop #~(make-kill-destructor))
           (respawn? #f))))
   (simple-service
    'sheng-wireplumber-audio etc-service-type
    (list (list "wireplumber/wireplumber.conf.d/11-sheng-alsa-ucm.conf"
                (local-file "11-sheng-alsa-ucm.conf"))))))
