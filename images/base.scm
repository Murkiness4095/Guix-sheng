;; Load this adapter only from CI image declarations.
(use-modules (guix gexp)
             (modules sheng-bootloader)
             ((sheng system) #:prefix channel:))

(define sheng-root-initializer
  #~(lambda (root . arguments)
      (apply (@ (gnu build image) initialize-root-partition)
             root #:register-closures? #f arguments)
      (#$sheng-bootmenu-writer root)
      ;; Retain the exact Guix reference graphs for registration by the
      ;; caller, outside the image builder's SQLite locking environment.
      (let* ((directory (string-append root "/var/guix/sheng-reference-graphs"))
             (graphs (cadr (memq #:references-graphs arguments))))
        (mkdir directory)
        (let loop ((graphs graphs) (index 0))
          (unless (null? graphs)
            (copy-file (car graphs)
                       (string-append directory "/" (number->string index)))
            (loop (cdr graphs) (+ index 1)))))))

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

(define (sheng-os . arguments)
  (apply channel:sheng-os
         #:username desktop-username
         #:password-hash desktop-password-hash
         #:auto-login? desktop-auto-login?
         #:vendor-services? sheng-vendor-services?
         arguments))
