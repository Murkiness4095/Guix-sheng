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
  #:use-module ((gnu packages fcitx5)
              #:select (fcitx5 fcitx5-chinese-addons fcitx5-configtool
                        fcitx5-gtk fcitx5-gtk4 fcitx5-qt fcitx5-rime))
  #:use-module ((gnu packages fonts) #:select (font-google-noto-sans-cjk))
  #:use-module ((gnu packages gnome) #:select (adwaita-icon-theme))
  #:use-module (gnu packages linux)
  #:use-module ((gnu packages lxqt) #:select (pcmanfm-qt))
  #:use-module ((gnu packages qt) #:select (qtwayland))
  #:use-module ((gnu packages glib) #:select (dbus))
  #:use-module ((gnu packages ncurses) #:select (ncurses))
  #:use-module (gnu packages librewolf)
  #:use-module (gnu packages window-management)
  #:use-module ((gnu packages shells) #:select (fish))
  #:use-module ((gnu packages shellutils) #:select (starship))
  #:use-module ((gnu packages terminals) #:select (alacritty kitty))
  #:use-module ((gnu packages version-control) #:select (git))
  #:use-module ((gnu packages xdisorg) #:select (fuzzel))
  #:use-module ((gnu packages xorg) #:select (xwayland-satellite))
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (midnight packages noctalia)
  #:use-module (midnight packages noctalia-greeter)
  #:use-module (midnight services noctalia-greeter)
  #:use-module (modules camera)
  #:use-module (modules boot-slot)
  #:use-module (modules internal-storage)
  #:use-module (modules sheng-bootloader)
  #:use-module (packages kernel)
  #:use-module (packages sheng-niri)
  #:use-module (packages sheng-sddm)
  #:use-module (packages firmware)
  #:use-module (packages peripherals)
  #:use-module (packages zed)
  #:use-module (packages vscode)
  #:use-module (services accessories)
  #:use-module (services audio)
  #:use-module (services fingerprint)
  #:use-module (services adsprpcd)
  #:use-module (services grow-root)
  #:use-module (services keyboard-auth)
  #:use-module (services sensors)
  #:use-module (services serial-console)
  #:use-module (services thp)
  #:export (sheng-os))

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

(define %sheng-base-services
  (modify-services %base-services
    (guix-service-type config =>
      (guix-configuration
       (inherit config)
       (extra-options
        (append (guix-configuration-extra-options config)
                '("--cores=2" "--max-jobs=1")))))))

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

(define sheng-niri-dbus-daemon
  (program-file
   "sheng-niri-dbus-daemon"
   #~(let* ((daemon #$(file-append dbus "/bin/dbus-daemon"))
            (runtime (getenv "XDG_RUNTIME_DIR"))
            (bus (and runtime (string-append runtime "/bus")))
            (arguments (cdr (command-line))))
       (apply execl daemon "dbus-daemon"
              (if (and bus (not (file-exists? bus)))
                  (cons (string-append "--address=unix:path=" bus) arguments)
                  arguments)))))

(define sheng-niri-session
  (program-file
   "sheng-niri-session"
   #~(begin
       (setenv "PATH" (string-append #$(file-append dbus "/bin")
                                    ":" (or (getenv "PATH") "")))
       (let* ((home (getenv "HOME"))
              (config-home (or (getenv "XDG_CONFIG_HOME")
                               (and home (string-append home "/.config"))))
              (config (and config-home
                           (string-append config-home "/niri/config.kdl")))
              (use-home? (and (equal? (getenv "SHENG_NIRI_USE_HOME_CONFIG") "1")
                              config (file-exists? config)))
              (dbus-run #$(file-append dbus "/bin/dbus-run-session"))
              (niri-bin #$(file-append niri "/bin/niri")))
         (if use-home?
             (execl dbus-run "dbus-run-session"
                    (string-append "--dbus-daemon=" #$sheng-niri-dbus-daemon)
                    "--" niri-bin "-c" config
                    "--" "/etc/sheng/niri-startup" "--home")
             (execl dbus-run "dbus-run-session"
                    (string-append "--dbus-daemon=" #$sheng-niri-dbus-daemon)
                    "--" niri-bin
                    "-c" "/etc/sheng/niri-noctalia.kdl"))))))


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
             (command sheng-niri-session)
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
                     (sddm sheng-sddm)
                     (auto-login-user (if auto-login? username ""))
                     (auto-login-session (if auto-login? "plasma.desktop" ""))))))
    ((gnome)
     (list (service gdm-service-type
                    (gdm-configuration
                     (auto-login? auto-login?)
                     (default-user (and auto-login? username))))))
    ((niri)
     (list (service noctalia-greeter-service-type)
           (service greetd-service-type (sheng-greetd-config desktop auto-login? username))))
    (else '())))

(define* (sheng-os #:key (desktop 'tty) (hostname "guix") (root-label "linux")
                   (username "sheng") (password-hash #f)
                   (auto-login? #t) (vendor-services? #f))
  "Return an <operating-system>.  DESKTOP: tty, kde, gnome, niri."
  (let* ((desktop-service
          (case desktop
            ((kde) (list (service plasma-desktop-service-type)))
            ((gnome) (list (service gnome-desktop-service-type)))
            (else '())))
         (session-pkgs
          (case desktop
            ((niri) (list niri noctalia fuzzel pcmanfm-qt adwaita-icon-theme
                          qtwayland xwayland-satellite
                          (sheng-niri-desktop "niri-sheng"
                                              sheng-niri-session)))
            (else '())))
         (noctalia-config
          (if (eq? desktop 'niri)
              (list (extra-special-file
                     "/etc/sheng/niri-noctalia.kdl"
                     (mixed-text-file
                      "niri-noctalia.kdl"
                      "include \""
                      (file-append niri-default-config "/share/niri/default-config.kdl")
                      "\"\noutput \"DSI-1\" { mode \"3048x2032@120\"; }\n"
                      "spawn-at-startup \"/etc/sheng/niri-startup\"\n"))
                    (extra-special-file "/etc/sheng/niri-startup"
                      (program-file
                       "sheng-niri-startup"
                       #~(begin
                           (define (spawn program . arguments)
                             (when (zero? (primitive-fork))
                               (apply execl program program arguments)))
                           (spawn #$(file-append pipewire "/bin/pipewire"))
                           (let wait ((attempts 50))
                             (unless (or (zero? attempts)
                                         (file-exists?
                                          (string-append (getenv "XDG_RUNTIME_DIR")
                                                         "/pipewire-0")))
                               (usleep 100000)
                               (wait (- attempts 1))))
                           (spawn #$(file-append pipewire "/bin/pipewire-pulse"))
                           (spawn #$(file-append wireplumber "/bin/wireplumber"))
                           (unless (member "--home" (cdr (command-line)))
                             (spawn #$(file-append noctalia "/bin/noctalia"))
                             (spawn #$(file-append fcitx5 "/bin/fcitx5")))
                           #$(if vendor-services?
                                 #~(begin
                                     (spawn #$(file-append sheng-pen-status "/bin/xiaomi-pen-status"))
                                     (spawn #$(file-append sheng-keyboard-helper
                                                          "/libexec/xiaomi-sheng-keyboard-helper")
                                            "--micmute"))
                                 #~#t)))))
              '()))
         (browser (if (eq? desktop 'tty) '() (list librewolf))))
    (operating-system
      (host-name hostname)
      (timezone "Asia/Shanghai")
      (locale "en_US.utf8")
      (kernel linux-sheng)
      ;; UFS, its Qualcomm platform driver, and ext4 are built into linux-sheng.
      ;; Include the configured USB keyboard modules instead of the generic PC list.
      (initrd-modules (list "usbhid" "hid-generic"))
      (kernel-arguments
       (list "video=DSI-1:3048x2032@120"
             "g_serial.use_acm=1" "console=ttyMSM0,115200n8" "console=ttyGS0,115200n8"
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
                            (list alacritty kitty sheng-zed sheng-vscode brightnessctl font-google-noto-sans-cjk
                                  fcitx5 fcitx5-chinese-addons fcitx5-rime
                                  fcitx5-configtool fcitx5-gtk fcitx5-gtk4 fcitx5-qt))
                        (if (memq desktop '(tty niri kde gnome))
                            (list fastfetch-minimal)
                            '())
                        (if (and vendor-services? (not (eq? desktop 'tty)))
                            (list sheng-pen-status)
                            '())
                        browser session-pkgs %base-packages))
      (services
       (append
        ;; Keep a text getty only for the tty image; graphical variants
        ;; replace it with their own display manager.
        (if (eq? desktop 'tty)
            (modify-services %sheng-base-services
              (mingetty-service-type config =>
                (if (and auto-login?
                         (string=? (mingetty-configuration-tty config) "tty1"))
                    (mingetty-configuration
                     (inherit config)
                     (auto-login username))
                    config)))
            (modify-services %sheng-base-services
              (delete mingetty-service-type)
              (delete console-font-service-type)))
        (sheng-desktop-services)
        (list (sheng-boot-slot)
              (sheng-serial-console)
              (sheng-grow-root-service root-label)
              (sheng-internal-storage)
              (sheng-keyboard-auth-service))
        desktop-service
        (if (eq? desktop 'niri)
            (list (extra-special-file
                   "/etc/xdg/pcmanfm-qt/default/settings.conf"
                   (plain-file "pcmanfm-qt-settings.conf"
                               "[System]\nFallbackIconThemeName=Adwaita\n")))
            '())
        (if (eq? desktop 'tty)
            '()
            (list (udev-rules-service 'sheng-backlight brightnessctl)))
        (if (eq? desktop 'kde)
            (list (extra-special-file
                   "/etc/sddm.conf.d/20-sheng-keyboard.conf"
                   (plain-file "sheng-sddm-keyboard.conf"
                               "[General]\nInputMethod=qtvirtualkeyboard\n")))
            '())
        (if vendor-services?
            (append
             (sheng-audio-services)
             (list (sheng-thp-service)
                   (service sheng-adsprpcd-service-type)
                   (sheng-sensors-service)
                   (sheng-keyboard-angle-service)
                   (sheng-mipps-service)
                   (sheng-mipps-udev-service)
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
                (list (service ntp-service-type)
                      (service openssh-service-type))))))))
