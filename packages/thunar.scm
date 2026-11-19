(define-module (packages thunar)
  #:use-module (gnu packages xfce)
  #:use-module (guix base16)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:export (sheng-thunar))

(define sheng-thunar
  (package
    (inherit thunar)
    ;; The upstream release includes configure and thunar-marshal.c.
    (source
     (origin
       (method url-fetch)
       (uri "https://archive.xfce.org/src/xfce/thunar/4.20/thunar-4.20.10.tar.bz2")
       (sha256
        (base16-string->bytevector
         "a5a32b51028dc821155e44cdec025fe70398bae193c619ae6ba8b1babf6f49f1"))))
    (arguments
     (substitute-keyword-arguments (package-arguments thunar)
       ((#:configure-flags _)
        #~'("--enable-gtk-doc" "--with-custom-thunarx-dirs-enabled"))
       ((#:phases phases #~%standard-phases)
        #~(modify-phases #$phases
            (delete 'bootstrap)))))))
