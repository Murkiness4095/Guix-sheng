;; system.scm — top-level Guix System declaration for sheng.
(use-modules (gnu)
             (modules boot)
             (modules filesystems)
             (modules networking))

(operating-system
  (host-name "sheng")
  (timezone "Asia/Shanghai")
  (locale "en_US.utf8")
  (bootloader sheng-bootloader)
  (file-systems (append (sheng-file-systems) %base-file-systems))
  (services (append (sheng-networking-services) %base-services))
  (packages %base-packages))
