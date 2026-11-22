(define-module (services desktop-config)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (guix gexp)
  #:export (sheng-desktop-config-service))

(define (sheng-desktop-config-service username)
  (let ((config
         (computed-file
          "sheng-noctalia.toml"
          (with-imported-modules '((guix build utils))
            #~(begin
                (use-modules (guix build utils))
                (copy-file #$(local-file "../config/noctalia/config.toml") #$output)
                (chmod #$output #o644)
                (substitute* #$output
                  (("@WALLPAPERS@") #$(local-file "../config/assets/wallpapers" #:recursive? #t))
                  (("@LAUNCHER_LOGO@") #$(local-file "../config/assets/nixos-logo.png"))))))))
    (simple-service
     'sheng-desktop-config activation-service-type
     (with-imported-modules '((guix build utils))
       #~(begin
           (use-modules (guix build utils))
           (let* ((user (getpwnam #$username))
                  (directory (string-append (passwd:dir user) "/.config/noctalia"))
                  (target (string-append directory "/config.toml")))
             (unless (file-exists? target)
               (mkdir-p directory)
               (copy-file #$config target)
               (chmod target #o644)
               (for-each (lambda (path)
                           (chown path (passwd:uid user) (passwd:gid user)))
                         (list (dirname directory) directory target)))))))))
