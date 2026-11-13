;; Minimal Guix system example for sheng (single system, ext4 root).
(use-modules (gnu))
(operating-system
  (host-name "sheng")
  (timezone "Asia/Shanghai")
  (locale "en_US.utf8")
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets '("/dev/mmcblk0"))))
  (file-systems (cons* (file-system (mount-point "/") (device (file-system-label "linux")) (type "ext4"))
                        %base-file-systems))
  (services %base-services))
