;; Dual system example: Guix on B slot (linux), keep Android on A.
(use-modules (gnu) (gnu bootloader u-boot))
(operating-system
  (host-name "sheng-dual")
  (timezone "Asia/Shanghai")
  (locale "en_US.utf8")
  (bootloader (bootloader-configuration
                (bootloader u-boot-bootloader)
                (targets '("/dev/mmcblk0"))))
  (file-systems (cons* (file-system (mount-point "/") (device (file-system-label "linux")) (type "ext4"))
                        %base-file-systems))
  (services %base-services))
