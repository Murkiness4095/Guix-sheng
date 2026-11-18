;; Public system declaration for the Guix-sheng channel.
(define-module (sheng system)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services desktop)
  #:use-module (gnu services dbus)
  #:use-module (gnu services ssh)
  #:use-module (gnu services networking)
  #:use-module (gnu services sddm)
  #:use-module (gnu services sound)
  #:use-module (gnu services xorg)
  #:use-module ((gnu packages admin) #:select (fastfetch-minimal))
  #:use-module (gnu packages display-managers)
  #:use-module ((gnu packages text-editors) #:select (zed))
  #:use-module ((gnu packages fcitx5)
              #:select (fcitx5 fcitx5-chinese-addons fcitx5-configtool
                        fcitx5-gtk fcitx5-gtk4 fcitx5-qt))
  #:use-module (gnu packages linux)
  #:use-module ((gnu packages ncurses) #:select (ncurses))
  #:use-module (gnu packages librewolf)
  #:use-module (gnu packages window-management)
  #:use-module ((gnu packages shells) #:select (fish))
  #:use-module ((gnu packages shellutils) #:select (starship))
  #:use-module ((gnu packages terminals) #:select (kitty))
  #:use-module ((gnu packages version-control) #:select (git))
  #:use-module ((gnu packages xdisorg) #:select (fuzzel))
  #:use-module (guix packages)
  #:use-module (guix base16)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (midnight packages noctalia)
  #:use-module ((midnight packages noctalia-greeter) #:prefix midnight:)
  #:use-module (midnight services noctalia-greeter)
  #:use-module (modules camera)
  #:use-module (modules internal-storage)
  #:use-module (modules sheng-bootloader)
  #:use-module (packages kernel)
  #:use-module (packages firmware)
  #:use-module (services accessories)
  #:use-module (services audio)
  #:use-module (services fingerprint)
  #:use-module (services adsprpcd)
  #:use-module (services grow-root)
  #:use-module (services keyboard-auth)
  #:use-module (services sensors)
  #:use-module (services thp)
  #:export (sheng-os))

;; Preserve midnight's pinned greeter revision without a Git checkout in CI.
(define noctalia-greeter
  (package
    (inherit midnight:noctalia-greeter)
    (source
     (origin
       (inherit (package-source midnight:noctalia-greeter))
       (method url-fetch)
       (uri (string-append "https://codeload.github.com/noctalia-dev/noctalia-greeter/tar.gz/"
                           "af0bf4b1e1c40738db917b04c9c0563b4f718953"))
       (file-name "noctalia-greeter-1.7.0.tar.gz")
       (sha256
        (base16-string->bytevector
         "f62b35c1511fba8c42b35cffb627b5b34f8a4b1cfba48f760d9f8b073b45abb4"))))))

(define (sheng-niri-desktop desktop-name exec-line)
  "Package providing a wayland-session desktop entry."
  (package
    (name (string-append "sheng-session-" desktop-name))
    (version "0")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list #:modules '((guix build utils))
           #:builder
           #~(begin
               (use-modules (guix build utils) (ice-9 format))
               (let ((dir (string-append #$output "/share/wayland-sessions")))
                 (mkdir-p dir)
                 (call-with-output-file (string-append dir "/" #$desktop-name ".desktop")
                   (lambda (p)
                     (format p "[Desktop Entry]~%Name=~a~%Exec=~a~%Type=Application~%"
                             #$desktop-name #$exec-line)))))))
    (synopsis "sheng desktop session entry")
    (description "Installs a wayland-sessions desktop entry.")
    (home-page "https://github.com/Murkiness4095/Guix-sheng")
    (license #f)))

(define (sheng-desktop-services)
  (list (service dbus-root-service-type)
        (service elogind-service-type)
        (service polkit-service-type)
        (simple-service
         'sheng-networkmanager-authorization polkit-service-type
         (list (file-union
                "sheng-networkmanager-polkit"
                `(("share/polkit-1/rules.d/49-sheng-networkmanager.rules"
                   ,(local-file "../services/polkit/49-sheng-networkmanager.rules"))))))
        (service accountsservice-service-type)
        (service upower-service-type)
        ;; NetworkManager's default shepherd requirement is 'wireless-daemon,
        ;; which wpa-supplicant provides.
        (service wpa-supplicant-service-type)
        (service network-manager-service-type)
        (service bluetooth-service-type)))

(define (sheng-greetd-config desktop auto-login? username)
  (greetd-configuration
   (greeter-supplementary-groups '("video" "input"))
   (terminals
    (list (greetd-terminal-configuration
           (terminal-vt "1")
           (terminal-switch #t)
           (extra-shepherd-requirement '(elogind))
           (initial-session-user (and auto-login? username))
           (initial-session-command
            (greetd-user-session
             (command (file-append niri "/bin/niri"))
             (command-args
              (if (eq? desktop 'noctalia)
                  '("-c" "/etc/sheng/niri-noctalia.kdl")
                  '()))
             (xdg-session-type "wayland")))
           (default-session-command
            (greetd-noctalia-greeter-session
             (package noctalia-greeter))))
          (greetd-terminal-configuration (terminal-vt "2"))
          (greetd-terminal-configuration (terminal-vt "3"))
          (greetd-terminal-configuration (terminal-vt "4"))
          (greetd-terminal-configuration (terminal-vt "5"))
          (greetd-terminal-configuration (terminal-vt "6"))))))

(define (sheng-login-services desktop auto-login? username)
  "Return the display manager for DESKTOP.
KDE and GNOME use their own greeters; niri sessions use the noctalia greeter.
The tty image keeps a text getty from %base-services."
  (case desktop
    ((kde)
     (list (service sddm-service-type
                    (sddm-configuration
                     (sddm sddm)
                     (auto-login-user (if auto-login? username ""))
                     (auto-login-session (if auto-login? "plasma.desktop" ""))))))
    ((gnome)
     (list (service gdm-service-type
                    (gdm-configuration
                     (auto-login? auto-login?)
                     (default-user (and auto-login? username))))))
    ((niri noctalia)
     (list (service noctalia-greeter-service-type)
           (service greetd-service-type (sheng-greetd-config desktop auto-login? username))))
    (else '())))

(define* (sheng-os #:key (desktop 'tty) (hostname "guix") (root-label "linux")
                   (username "sheng") (password-hash #f)
                   (auto-login? #t) (vendor-services? #f))
  "Return an <operating-system>.  DESKTOP: tty, kde, gnome, niri, noctalia."
  (let* ((desktop-service
          (case desktop
            ((kde) (list (service plasma-desktop-service-type)))
            ((gnome) (list (service gnome-desktop-service-type)))
            (else '())))
         (session-pkgs
          (case desktop
            ((niri) (list niri fuzzel (sheng-niri-desktop "niri" "niri")))
            ((noctalia) (list niri noctalia
                               (sheng-niri-desktop "niri-noctalia"
                                                   "niri -c /etc/sheng/niri-noctalia.kdl")))
            (else '())))
         (noctalia-config
          (if (eq? desktop 'noctalia)
              (list (extra-special-file
                     "/etc/sheng/niri-noctalia.kdl"
                     (plain-file "niri-noctalia.kdl"
                                 "spawn-at-startup \"noctalia\"\n")))
              '()))
         (browser (list librewolf)))
    (operating-system
      (host-name hostname)
      (timezone "Asia/Shanghai")
      (locale "en_US.utf8")
      (kernel linux-sheng)
      ;; UFS, its Qualcomm platform driver, and ext4 are built into linux-sheng.
      ;; Include the configured USB keyboard modules instead of the generic PC list.
      (initrd-modules (list "usbhid" "hid-generic"))
      (kernel-arguments
       (list "console=ttyMSM0,115200n8" "console=ttyGS0,115200n8"
             "console=tty0" "fbcon=map:0" "loglevel=4" "rootwait"))
      (firmware (cons* sheng-firmware %base-firmware))
      (bootloader (bootloader-configuration
                    (bootloader sheng-extlinux-bootloader)
                    (targets '("/dev/mmcblk0"))))
      (file-systems (cons* (file-system
                             (mount-point "/")
                             (device (file-system-label root-label))
                             (type "ext4"))
                           %base-file-systems))
      (users (cons* (user-account
                      (name username)
                      (shell (file-append fish "/bin/fish"))
                      (password password-hash)
                      (group "users")
                      (supplementary-groups '("wheel" "netdev" "audio" "video" "input"))
                      (home-directory (string-append "/home/" username)))
                    (user-account
                      (name "greeter")
                      (group "greeter")
                      (supplementary-groups '("video" "input"))
                      (home-directory "/var/lib/noctalia-greeter"))
                    %base-user-accounts))
      (groups (cons* (user-group (name "greeter")) %base-groups))
      (packages (append (list ncurses fish starship git)
                        (if (eq? desktop 'tty)
                            '()
                            (list kitty zed fcitx5 fcitx5-chinese-addons
                                  fcitx5-configtool fcitx5-gtk fcitx5-gtk4 fcitx5-qt))
                        (if (memq desktop '(tty niri kde gnome))
                            (list fastfetch-minimal)
                            '())
                        browser session-pkgs %base-packages))
      (services
       (append
        ;; Keep a text getty only for the tty image; graphical variants
        ;; replace it with their own display manager.
        (if (eq? desktop 'tty)
            (modify-services %base-services
              (mingetty-service-type config =>
                (if (and auto-login?
                         (string=? (mingetty-configuration-tty config) "tty1"))
                    (mingetty-configuration
                     (inherit config)
                     (auto-login username))
                    config)))
            (modify-services %base-services
              (delete mingetty-service-type)
              (delete console-font-service-type)))
        (sheng-desktop-services)
        (list (sheng-grow-root-service root-label)
              (sheng-internal-storage)
              (sheng-keyboard-auth-service))
        desktop-service
        (if vendor-services?
            (append
             (sheng-audio-services)
             (list (sheng-thp-service)
                   (service sheng-adsprpcd-service-type)
                   (sheng-sensors-service)
                   (sheng-keyboard-angle-service)
                   (sheng-mipps-service)
                   (sheng-keyboard-led-service)
                   (sheng-charger-mode-service))
             (if (eq? desktop 'tty)
                 '()
                 (append (list (sheng-pen-autostart-service)
                               (sheng-keyboard-micmute-service))
                         (sheng-camera)
                         (sheng-fingerprint-services))))
            '())
        noctalia-config
        (append (sheng-login-services desktop auto-login? username)
                (list (service openssh-service-type))))))))
