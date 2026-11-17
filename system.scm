;; Top-level sheng system declaration for an ext4 root labelled linux.
(load (string-append (dirname (current-filename)) "/images/base.scm"))

(sheng-os #:desktop 'tty #:root-label "linux")
