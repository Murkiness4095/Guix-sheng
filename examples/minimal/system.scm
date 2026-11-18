;; Bootable sheng TTY system, using the Guix-sheng channel.
(use-modules (sheng system))

(sheng-os #:desktop 'tty
          #:root-label "userdata"
          #:username "sheng")
