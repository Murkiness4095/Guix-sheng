;; niri's default key bindings, installed as a file so the sheng session
;; config can include them instead of replacing them.
(define-module (packages sheng-niri)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (niri-default-config))

(define niri-default-config
  (package
    (name "niri-default-config")
    (version "26.04")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://raw.githubusercontent.com/niri-wm/niri/v"
             version "/resources/default-config.kdl"))
       (sha256
        (base32 "106hd8ldshqr2902h64xdk2q055kqzaai1gdn0cdmsj7xl2s4flr"))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan '(("default-config.kdl" "share/niri/"))
       #:phases (modify-phases %standard-phases
                  (delete 'install-license-files))))
    (synopsis "Default niri configuration with key bindings")
    (description
     "Installs niri's resources/default-config.kdl so a session config can
include it and keep the default key bindings.")
    (home-page "https://github.com/niri-wm/niri")
    (license license:gpl3+)))
