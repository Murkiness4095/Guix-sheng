;; images/base.scm — shared sheng operating-system generator.
;; Load with (load (string-append (dirname (current-filename)) "/base.scm")).
(use-modules (gnu)
             (gnu bootloader u-boot)
             (gnu services)
             (gnu services base)
             (gnu services desktop)
             (gnu services dbus)
             (gnu services networking)
             (gnu services sound)
             (gnu packages linux)
             (gnu packages librewolf)
             (gnu packages window-management)
             (guix build-system trivial)
             (guix gexp)
             (midnight packages noctalia)
             (midnight services noctalia-greeter))

;; Build-time identity settings.  CI writes images/settings.scm from the
;; workflow inputs; local builds fall back to these defaults.
(define settings-file
  (string-append (dirname (current-filename)) "/settings.scm"))
(if (file-exists? settings-file) (load settings-file))
(define desktop-username
  (if (defined? 'sheng-desktop-username) sheng-desktop-username "sheng"))
(define desktop-password-hash
  (if (defined? 'sheng-desktop-password-hash) sheng-desktop-password-hash #f))

(define (sheng-niri-desktop desktop-name exec-line)
  "Package providing a wayland-session desktop entry."
  (package
    (name (string-append "sheng-session-" desktop-name))
    (version "0")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list #:builder
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
  (list (service elogind-service-type)
        (service polkit-service-type)
        (service accountsservice-service-type)
        (service upower-service-type)
        (service network-manager-service-type)
        (service bluetooth-service-type)
        (service pipewire-service-type)))

(define (sheng-greetd-config)
  (greetd-configuration
   (greeter-supplementary-groups '("video" "input"))
   (terminals
    (list (greetd-terminal-configuration
           (terminal-vt "1")
           (terminal-switch #t)
           (extra-shepherd-requirement '(elogind))
           (default-session-command
            (greetd-noctalia-greeter-session
             (package noctalia-greeter))))
          (greetd-terminal-configuration (terminal-vt "2"))
          (greetd-terminal-configuration (terminal-vt "3"))
          (greetd-terminal-configuration (terminal-vt "4"))
          (greetd-terminal-configuration (terminal-vt "5"))
          (greetd-terminal-configuration (terminal-vt "6"))))))

(define* (sheng-os #:key (desktop 'tty) (hostname "sheng") (root-label "linux"))
  "Return an <operating-system>.  DESKTOP: tty, kde, gnome, niri, noctalia."
  (let* ((desktop-service
          (case desktop
            ((kde) (list (service plasma-desktop-service-type)))
            ((gnome) (list (service gnome-desktop-service-type)))
            (else '())))
         (session-pkgs
          (case desktop
            ((niri) (list niri (sheng-niri-desktop "niri" "niri")))
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
      (bootloader (bootloader-configuration
                    (bootloader u-boot-bootloader)
                    (targets '("/dev/mmcblk0"))))
      (file-systems (cons* (file-system
                             (mount-point "/")
                             (device (file-system-label root-label))
                             (type "ext4"))
                           %base-file-systems))
      (users (cons* (user-account
                      (name desktop-username)
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
      (packages (append browser session-pkgs %base-packages))
      (services
       (append
        (modify-services %base-services
          (delete mingetty-service-type))
        (sheng-desktop-services)
        desktop-service
        noctalia-config
        (list (service noctalia-greeter-service-type)
              (service greetd-service-type (sheng-greetd-config))
              (service openssh-service-type)))))))
