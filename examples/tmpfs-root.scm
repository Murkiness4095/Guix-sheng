;; 易失根 + 选择性持久化样板（对应 nixos-sheng 的 tmpfs-root.nix）。
;; 根为 tmpfs，/persist 是原 ext4 分区；只绑定声明过的目录。
(use-modules (gnu)
             (gnu bootloader u-boot)
             (gnu system file-systems))

(define persist-device (file-system-label "linux"))

(operating-system
  (host-name "sheng")
  (timezone "Asia/Shanghai")
  (locale "en_US.utf8")
  (bootloader (bootloader-configuration
                (bootloader u-boot-bootloader)
                (targets '("/dev/mmcblk0"))))
  (file-systems
   (cons* (file-system
            (mount-point "/")
            (device "tmpfs")
            (type "tmpfs")
            (options "size=4G"))
          (file-system
            (mount-point "/persist")
            (device persist-device)
            (type "ext4"))
          ;; 只保留声明过的状态；未声明的 home/缓存重启清空。
          (file-system (mount-point "/persist/etc/ssh")
                       (device "/persist/etc/ssh")
                       (type "none")
                       (dependencies '("/persist")))
          (file-system (mount-point "/persist/var/lib/bluetooth")
                       (device "/persist/var/lib/bluetooth")
                       (type "none")
                       (dependencies '("/persist")))
          %base-file-systems))
  (services %base-services))
