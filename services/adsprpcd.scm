;; Serve the mutable SSC sensor registry to the audio DSP.
(define-module (services adsprpcd)
  #:use-module (gnu packages base)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (packages peripherals)
  #:export (sheng-adsprpcd-service-type))

(define start-adsprpcd
  (program-file
   "start-sheng-adsprpcd"
   #~(begin
       (let* ((registry "/var/lib/qcom")
              (stamp (string-append registry "/.guix-source"))
              (source #$(file-append sheng-sensors "/share/qcom"))
              (saved-source (and (file-exists? stamp)
                                 (call-with-input-file stamp read))))
         (unless (equal? saved-source source)
           (unless (file-exists? registry) (mkdir registry #o755))
           (unless (zero? (system* #$(file-append coreutils "/bin/cp") "-R"
                                   "--no-preserve=mode,ownership"
                                   (string-append source "/.") registry))
             (error "Could not seed the sheng sensor registry"))
           (call-with-output-file stamp (lambda (port) (write source port)))))
       (let wait-for-dsp ()
         (unless (or (file-exists? "/dev/fastrpc-adsp")
                     (file-exists? "/dev/fastrpc-adsp-secure"))
           (sleep 1)
           (wait-for-dsp)))
       (let ((program #$(file-append sheng-fastrpc "/bin/adsprpcd")))
         (execl program program "sensorspd")))))

(define sheng-adsprpcd-service-type
  (service-type
   (name 'sheng-adsprpcd)
   (extensions
    (list
     (service-extension
      shepherd-root-service-type
      (lambda (_)
        (list
         (shepherd-service
          (provision '(sheng-adsprpcd))
          (requirement '(user-processes udev))
          (documentation "Start the FastRPC sensor DSP daemon.")
          (start #~(make-forkexec-constructor (list #$start-adsprpcd)))
          (stop #~(make-kill-destructor))
          (respawn? #t)))))))
   (default-value #t)
   (description "Seed the mutable SSC registry and start the FastRPC sensor daemon.")))
