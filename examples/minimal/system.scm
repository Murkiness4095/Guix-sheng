;; Minimal sheng system using the same extlinux path as single-tty.
(load (string-append (dirname (current-filename)) "/../../images/base.scm"))

(sheng-os #:desktop 'tty #:root-label "userdata")
