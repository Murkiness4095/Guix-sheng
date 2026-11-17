(define-module (services sensors)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services dbus)
  #:use-module (gnu services desktop)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (packages peripherals)
  #:export (sheng-sensors-service))

(define start-sensor-proxy
  (program-file
   "start-sheng-sensor-proxy"
   #~(begin
       (let wait-for-dsp ()
         (unless (or (file-exists? "/dev/fastrpc-adsp")
                     (file-exists? "/dev/fastrpc-adsp-secure"))
           (sleep 1)
           (wait-for-dsp)))
       ;; The NixOS unit waits for the SSC endpoint to enumerate on QRTR.
       (sleep 8)
       (let ((program #$(file-append sheng-iio-sensor-proxy
                                      "/libexec/iio-sensor-proxy")))
         (execl program program)))))

(define sheng-sensors-service-type
  (service-type
   (name 'sheng-sensors)
   (extensions
    (list (service-extension dbus-root-service-type
                             (lambda (_) (list sheng-iio-sensor-proxy)))
          (service-extension polkit-service-type
                             (lambda (_) (list sheng-iio-sensor-proxy)))
          (service-extension udev-service-type
                             (lambda (_) (list sheng-iio-sensor-proxy sheng-sensors)))
          (service-extension
           shepherd-root-service-type
           (lambda (_)
             (list
              (shepherd-service
               (provision '(iio-sensor-proxy))
               (requirement '(dbus-system udev sheng-adsprpcd))
               (documentation "Expose sheng SSC sensors over D-Bus.")
               (start #~(make-forkexec-constructor (list #$start-sensor-proxy)))
               (stop #~(make-kill-destructor))
               (respawn? #t)))))))
   (default-value #t)
   (description "Run the sheng IIO sensor proxy with Qualcomm SSC support.")))

(define (sheng-sensors-service)
  (service sheng-sensors-service-type))
