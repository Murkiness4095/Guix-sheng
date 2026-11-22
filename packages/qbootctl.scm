(define-module (packages qbootctl)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix base16)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (qbootctl))

(define qbootctl
  (package
    (name "qbootctl")
    (version "0.2.2")
    (source (origin
              (method url-fetch)
              (uri "https://codeload.github.com/linux-msm/qbootctl/tar.gz/refs/tags/0.2.2")
              (sha256 (base16-string->bytevector
                       "e66b361f86fac413f6a96974b4045a1fbc385f9eb6cee7fa8a26e0ca77c74a51"))))
    (build-system meson-build-system)
    (home-page "https://github.com/linux-msm/qbootctl")
    (synopsis "Qualcomm boot slot control")
    (description "Marks the running Qualcomm A/B boot slot successful.")
    (license license:gpl3)))
