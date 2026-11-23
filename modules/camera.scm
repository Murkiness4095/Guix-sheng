(define-module (modules camera)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages linux)
  #:use-module ((gnu packages photo) #:select (libcamera))
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu system pam)
  #:use-module (guix gexp)
  #:export (sheng-camera))

(define (sheng-camera)
  (list
   (simple-service
    'sheng-camera-wireplumber etc-service-type
    (list (list "wireplumber/wireplumber.conf.d/10-sheng-libcamera.conf"
                (plain-file "10-sheng-libcamera.conf"
                            "wireplumber.profiles = { main = { monitor.libcamera = required monitor.v4l2 = disabled } }\n"))))
   (simple-service
    'sheng-camera-gstreamer session-environment-service-type
    `(("QT_MEDIA_BACKEND" . "gstreamer")
      ("GST_PLUGIN_SYSTEM_PATH_1_0"
       . ,(directory-union "sheng-gstreamer-plugins"
                            (cons (computed-file "libcamera-gst-plugins"
                                   #~(symlink (string-append #$libcamera:gst "/lib/gstreamer-1.0")
                                              #$output))
                                  (map (lambda (package)
                                         (file-append package "/lib/gstreamer-1.0"))
                                       (list gst-plugins-base gst-plugins-good pipewire)))))))))
