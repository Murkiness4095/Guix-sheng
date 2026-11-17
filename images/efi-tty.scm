;; Guix standard GRUB EFI layout, split into ESP and rootfs by EFI CI.
(load (string-append (dirname (current-filename)) "/base.scm"))
(use-modules (gnu bootloader grub)
             (gnu image)
             (gnu packages bootloaders)
             (gnu system image))

(define root-label
  (case (string->symbol (or (getenv "SHENG_EFI_LAYOUT") "single"))
    ((single) "userdata")
    ((dual) "linux")
    (else (error "Unknown SHENG_EFI_LAYOUT"))))

(define the-os
  (operating-system
    (inherit (sheng-os #:desktop 'tty #:root-label root-label))
    (bootloader (bootloader-configuration
                  (bootloader grub-efi-removable-bootloader)
                  (targets '("/boot/efi"))))
    (file-systems
     (cons* (file-system
              (mount-point "/boot/efi")
              (device (file-system-label "SHENG-ESP"))
              (type "vfat"))
            (file-system
              (mount-point "/")
              (device (file-system-label root-label))
              (type "ext4"))
            %base-file-systems))))

(image
 (inherit efi-disk-image)
 (operating-system the-os)
 (partitions
  (list (partition
         (inherit esp-partition/grub)
         (size (* 512 (expt 2 20)))
         (label "SHENG-ESP")
         (file-system "fat32")
         (initializer
          #~(lambda* (root #:key #:allow-other-keys)
              ((@ (gnu build image) initialize-efi-partition)
               root #:grub-efi #$grub-efi)
              (copy-file #$(file-append linux-sheng "/" sheng-dtb-path)
                         (string-append root "/sheng.dtb")))))
        (partition
         (inherit root-partition)
         (label "Guix_image")
         (initializer
          #~(lambda (root . args)
              (apply (@ (gnu build image) initialize-root-partition)
                     root
                     (append args
                             (list #:register-closures? #f
                                   #:wal-mode? #f)))))))))
