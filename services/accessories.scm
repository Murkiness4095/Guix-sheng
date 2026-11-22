(define-module (services accessories)
  #:use-module ((gnu packages base) #:select (coreutils))
  #:use-module ((gnu packages python) #:select (python))
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (packages peripherals)
  #:export (sheng-keyboard-angle-service
            sheng-mipps-service
            sheng-mipps-udev-service
            sheng-keyboard-led-service
            sheng-keyboard-micmute-service
            sheng-charger-mode-service
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
  (simple-service
   'sheng-mipps shepherd-root-service-type
   (list
    (shepherd-service
     (provision '(sheng-mipps))
     (requirement '(udev))
     (documentation "Process charger authentication requests from udev.")
     (start #~(make-forkexec-constructor
               (list #$(program-file
                        "sheng-mipps-monitor"
                        #~(let loop ((previous #f))
                            (let* ((request "/run/sheng-mipps-request")
                                   (current (and (file-exists? request)
                                                 (stat:mtime (stat request)))))
                              (unless (equal? current previous)
                                (system* #$(file-append util-linux "/bin/flock")
                                         "-n" "-E" "0" "/run/xiaomi-mipps-auth.lock"
                                         #$(file-append sheng-mipps-auth "/libexec/xiaomi-mipps-auth")
                                         "--timeout" "4"))
                              (sleep 1)
                              (loop current)))))))
     (stop #~(make-kill-destructor))
     (respawn? #t)))))

(define (sheng-mipps-udev-service)
  (udev-rules-service
   'sheng-mipps-trigger
   (file->udev-rule
    "90-sheng-mipps.rules"
    (mixed-text-file
     "90-sheng-mipps.rules"
     "ACTION==\"add\", SUBSYSTEM==\"typec\", KERNEL==\"port*-partner\", RUN+=\""
     (file-append coreutils "/bin/touch") " /run/sheng-mipps-request\"\n"
     "ACTION==\"change\", SUBSYSTEM==\"power_supply\", KERNEL==\"qcom-battmgr-usb\", ENV{POWER_SUPPLY_ONLINE}==\"1\", RUN+=\""
     (file-append sheng-mipps-auth "/libexec/xiaomi-mipps-auth") " --usb-online-trigger\"\n"
     "ACTION==\"change\", SUBSYSTEM==\"power_supply\", KERNEL==\"qcom-battmgr-usb\", ENV{POWER_SUPPLY_ONLINE}==\"0\", RUN+=\""
     (file-append sheng-mipps-auth "/libexec/xiaomi-mipps-auth") " --clear-notification\"\n"))))

(define (sheng-pen-autostart-service)
  (simple-service
   'sheng-pen-autostart etc-service-type
   (list
    (list "xdg/autostart/xiaomi-pen-status.desktop"
          (file-append sheng-pen-status
                       "/etc/xdg/autostart/xiaomi-pen-status.desktop")))))

(define (sheng-keyboard-led-service)
  (udev-rules-service
   'sheng-keyboard-led
   (file->udev-rule
    "90-sheng-keyboard-led.rules"
    (mixed-text-file "90-sheng-keyboard-led.rules"
     "ACTION==\"add\", SUBSYSTEM==\"leds\", KERNEL==\"nanosic:kbd_backlight|nanosic::kbd_backlight|nanosic::micmute\", "
     "RUN+=\"" (file-append coreutils "/bin/chgrp") " video /sys%p/brightness\", "
     "RUN+=\"" (file-append coreutils "/bin/chmod") " 0664 /sys%p/brightness\"\n"))))

(define (sheng-keyboard-micmute-service)
  (simple-service
   'sheng-keyboard-micmute etc-service-type
   (list
    (list "xdg/autostart/xiaomi-sheng-keyboard-micmute.desktop"
          (mixed-text-file
           "xiaomi-sheng-keyboard-micmute.desktop"
           "[Desktop Entry]\nType=Application\nName=Xiaomi keyboard mic mute\nExec="
           (file-append sheng-keyboard-helper "/libexec/xiaomi-sheng-keyboard-helper")
           " --micmute\n")))))

(define start-charger-mode
  (program-file
   "start-sheng-charger-mode"
   #~(begin
       (use-modules (ice-9 rdelim) (srfi srfi-13))
       (when (member "androidboot.mode=charger"
                     (string-tokenize (call-with-input-file "/proc/cmdline" read-line)))
         (let ((interpreter #$(file-append python "/bin/python3"))
               (program #$(file-append sheng-charger-mode "/libexec/xiaomi-charger-mode")))
           (execl interpreter interpreter program))))))

(define (sheng-charger-mode-service)
  (simple-service
   'sheng-charger-mode shepherd-root-service-type
   (list
    (shepherd-service
     (provision '(sheng-charger-mode))
     (requirement '(udev))
     (documentation "Run the sheng framebuffer UI when booted in charger mode.")
     (start #~(make-forkexec-constructor (list #$start-charger-mode)))
     (stop #~(make-kill-destructor))
     (respawn? #f)))))
