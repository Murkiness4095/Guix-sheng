(define-module (services fingerprint)
  #:use-module ((gnu packages freedesktop) #:select (fprintd))
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services dbus)
  #:use-module (gnu services desktop)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (packages firmware)
  #:use-module (packages peripherals)
  #:export (sheng-fingerprint-services))

(define sheng-fprintd
  (package
    (inherit fprintd)
    (name "sheng-fprintd")
    (arguments
     (substitute-keyword-arguments (package-arguments fprintd)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'install 'configure-sheng-backend
              (lambda _
                (wrap-program (string-append #$output "/libexec/fprintd")
                  `("LD_LIBRARY_PATH" ":" prefix
                    (,#$(file-append sheng-fingerprint "/lib/xiaomi-sheng-fingerprint")))
                  `("FPC1553_TA_PATH" =
                    (,#$(file-append sheng-firmware "/lib/firmware/fpcsheng.elf"))))))))))))

(define (sheng-fingerprint-services)
  (list (simple-service 'sheng-fprintd-dbus dbus-root-service-type
                        (list sheng-fprintd))
        (simple-service 'sheng-fprintd-polkit polkit-service-type
                        (list sheng-fprintd))
        (udev-rules-service 'sheng-fingerprint sheng-fingerprint)))
