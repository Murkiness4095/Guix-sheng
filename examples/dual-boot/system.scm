;; sheng 最小单系统：双系统：Android A 槽 / userdata，Guix B 槽 / linux。
(use-modules (gnu) (gnu bootloader u-boot))

(operating-system
  (host-name "sheng")
  (timezone "Asia/Shanghai")
  (locale "en_US.utf8")
  (bootloader (bootloader-configuration
                (bootloader u-boot-bootloader)
                (targets '("/dev/mmcblk0"))))
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (file-system-label "linux"))
                         (type "ext4"))
                       %base-file-systems))
  (users (cons* (user-account
                  (name "sheng")
                  (group "users")
                  (supplementary-groups '("wheel" "netdev" "audio" "video" "input"))
                  (home-directory "/home/sheng"))
                %base-user-accounts))
  (services %base-services))
