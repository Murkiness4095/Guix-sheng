;; images/base.scm — shared sheng operating-system generator.
;; Load with (load (string-append (dirname (current-filename)) "/base.scm")).
(use-modules (gnu)
             (gnu services)
             (gnu services base)
             (gnu services desktop)
             (gnu services dbus)
             (gnu services ssh)
             (gnu services networking)
             (gnu services sddm)
             (gnu services sound)
             (gnu services xorg)
             ((gnu packages admin) #:select (fastfetch-minimal))
             (gnu packages display-managers)
             ((gnu packages fcitx5)
              #:select (fcitx5 fcitx5-chinese-addons fcitx5-configtool
                        fcitx5-gtk fcitx5-gtk4 fcitx5-qt))
             (gnu packages linux)
             ((gnu packages ncurses) #:select (ncurses))
             (gnu packages librewolf)
             (gnu packages window-management)
             ((gnu packages shells) #:select (fish))
             ((gnu packages shellutils) #:select (starship))
             ((gnu packages terminals) #:select (kitty))
             ((gnu packages version-control) #:select (git))
             ((gnu packages xdisorg) #:select (fuzzel))
             (guix packages)
             (guix build-system trivial)
             (guix gexp)
             (midnight packages noctalia)
             (midnight packages noctalia-greeter)
             (midnight services noctalia-greeter)
             (modules sheng-bootloader)
             (packages kernel)
             (packages firmware)
             (services adsprpcd)
             (services grow-root)
             (services sensors)
             (services thp)
             (services ucm))

;; Build-time identity settings.  CI writes images/settings.scm from the
;; workflow inputs; local builds fall back to these defaults.
(define settings-file
  (string-append (dirname (current-filename)) "/settings.scm"))
(if (file-exists? settings-file) (load settings-file))
(define desktop-username
  (if (defined? 'sheng-desktop-username) sheng-desktop-username "sheng"))
(define desktop-password-hash
  (if (defined? 'sheng-desktop-password-hash) sheng-desktop-password-hash #f))

(define desktop-auto-login?
  (if (defined? 'sheng-desktop-auto-login?) sheng-desktop-auto-login? #t))

(define sheng-vendor-services?
  (and (defined? 'sheng-enable-vendor-services?) sheng-enable-vendor-services?))

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

(define (sheng-greetd-config desktop auto-login?)
  (greetd-configuration
   (greeter-supplementary-groups '("video" "input"))
   (terminals
    (list (greetd-terminal-configuration
           (terminal-vt "1")
           (terminal-switch #t)
           (extra-shepherd-requirement '(elogind))
           (initial-session-user (and auto-login? desktop-username))
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

(define (sheng-login-services desktop auto-login?)
  "Return the display manager for DESKTOP.
KDE and GNOME use their own greeters; niri sessions use the noctalia greeter.
The tty image keeps a text getty from %base-services."
  (case desktop
    ((kde)
     (list (service sddm-service-type
                    (sddm-configuration
                     (sddm sddm)
                     (auto-login-user (if auto-login? desktop-username ""))
                     (auto-login-session (if auto-login? "plasma.desktop" ""))))))
    ((gnome)
     (list (service gdm-service-type
                    (gdm-configuration
                     (auto-login? auto-login?)
                     (default-user (and auto-login? desktop-username))))))
    ((niri noctalia)
     (list (service noctalia-greeter-service-type)
           (service greetd-service-type (sheng-greetd-config desktop auto-login?))))
    (else '())))

(define* (sheng-os #:key (desktop 'tty) (hostname "guix") (root-label "linux")
                   (auto-login? desktop-auto-login?)
                   (vendor-services? sheng-vendor-services?))
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
                      (name desktop-username)
                      (shell (file-append fish "/bin/fish"))
                      (password desktop-password-hash)
                      (group "users")
                      (supplementary-groups '("wheel" "netdev" "audio" "video" "input"))
                      (home-directory (string-append "/home/" desktop-username)))
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
                            (list kitty fcitx5 fcitx5-chinese-addons
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
                     (auto-login desktop-username))
                    config)))
            (modify-services %base-services
              (delete mingetty-service-type)
              (delete console-font-service-type)))
        (sheng-desktop-services)
        (list (sheng-grow-root-service root-label))
        desktop-service
        (if vendor-services?
            (list (sheng-ucm-service) (sheng-thp-service)
                  (service sheng-adsprpcd-service-type)
                  (sheng-sensors-service))
            '())
        noctalia-config
        (append (sheng-login-services desktop auto-login?)
                (list (service openssh-service-type))))))))
