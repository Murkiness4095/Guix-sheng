;; sheng 桌面单系统：niri + noctalia + noctalia greeter + librewolf。
;; 需要先 guix pull -C channels.scm（含 midnight 频道）。
(use-modules (gnu)
             (gnu bootloader u-boot)
             (gnu services base)
             (gnu services desktop)
             (gnu services networking)
             (gnu services sound)
             (gnu packages librewolf)
             (gnu packages window-management)
             (midnight packages noctalia)
             (midnight services noctalia-greeter))

(define desktop-user "sheng")
(define desktop-password-hash #f) ; 用 (password ...) 填入 crypt 哈希

(operating-system
  (host-name "sheng")
  (timezone "Asia/Shanghai")
  (locale "en_US.utf8")
  (bootloader (bootloader-configuration
                (bootloader u-boot-bootloader)
                (targets '("/dev/mmcblk0"))))
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (file-system-label "userdata"))
                         (type "ext4"))
                       %base-file-systems))
  (users (cons* (user-account
                  (name desktop-user)
                  (password desktop-password-hash)
                  (group "users")
                  (supplementary-groups '("wheel" "netdev" "audio" "video" "input"))
                  (home-directory (string-append "/home/" desktop-user)))
                (user-account
                  (name "greeter")
                  (group "greeter")
                  (supplementary-groups '("video" "input"))
                  (home-directory "/var/lib/noctalia-greeter"))
                %base-user-accounts))
  (groups (cons* (user-group (name "greeter")) %base-groups))
  (packages (append (list librewolf niri noctalia) %base-packages))
  (services
   (append
    (modify-services %base-services
      (delete mingetty-service-type))
    (list (service elogind-service-type)
          (service polkit-service-type)
          (service accountsservice-service-type)
          (service upower-service-type)
          (service network-manager-service-type)
          (service bluetooth-service-type)
          (service pipewire-service-type)
          (service noctalia-greeter-service-type)
          (service greetd-service-type
                   (greetd-configuration
                    (greeter-supplementary-groups '("video" "input"))
                    (terminals
                     (list (greetd-terminal-configuration
                            (terminal-vt "1")
                            (terminal-switch #t)
                            (extra-shepherd-requirement '(elogind))
                            (default-session-command
                             (greetd-noctalia-greeter-session
                              (package noctalia-greeter)))))))))))
