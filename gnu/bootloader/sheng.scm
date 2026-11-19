;; Re-export the sheng bootloader where Guix's bootloader registry scans for
;; modules ("gnu/bootloader" in every channel of the current profile).
;; This makes 'guix system switch-generation' and 'roll-back' able to
;; reinstall sheng-extlinux on the tablet instead of failing with
;; "sheng-extlinux: no such bootloader".
(define-module (gnu/bootloader sheng)
  #:use-module (modules sheng-bootloader)
  #:re-export (sheng-extlinux-bootloader))
