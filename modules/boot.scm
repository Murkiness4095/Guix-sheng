(define-module (modules boot)
  #:use-module (gnu)
  #:use-module (gnu bootloader u-boot)
  #:export (sheng-bootloader))
(define sheng-bootloader
  (bootloader-configuration
    (bootloader u-boot-bootloader)
    (targets '("/dev/mmcblk0"))))
