;; Top-level extlinux configuration using the linux partition.
(use-modules (sheng system))

(sheng-os #:desktop 'tty #:root-label "linux")
