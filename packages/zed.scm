(define-module (packages zed)
  #:use-module (gnu packages base)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (guix base16)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (sheng-zed))

(define sheng-zed
  (package
    (name "zed")
    (version "1.26.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/zed-industries/zed/releases/download/v"
                           version "/zed-linux-aarch64.tar.gz"))
       (sha256
        (base16-string->bytevector
         "167c53a4b1ea13a788e6281269ccf0421b7fe77186267b4cd3d91e06a6fba928"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:strip-binaries? #f
      #:install-plan #~'(("bin" "bin") ("libexec" "libexec") ("share" "share")
                        ("licenses.md" "share/doc/zed/licenses.md"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'set-elf-runtime
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((loader (search-input-file inputs "/lib/ld-linux-aarch64.so.1"))
                     (libraries '("libgcc_s.so.1" "libstdc++.so.6" "libgio-2.0.so.0"
                                  "libasound.so.2" "libxcb.so.1" "libX11-xcb.so.1"
                                  "libxkbcommon.so.0" "libwayland-client.so.0"
                                  "libvulkan.so.1"))
                     (paths (map (lambda (library)
                                   (dirname (search-input-file
                                             inputs (string-append "/lib/" library))))
                                 libraries))
                     (rpath (string-join (cons (dirname loader) paths) ":")))
                (for-each
                 (lambda (program)
                   (invoke "patchelf" "--set-interpreter" loader "--set-rpath" rpath
                           (string-append #$output program)))
                 '("/bin/zed" "/libexec/zed-editor"))
                (wrap-program (string-append #$output "/libexec/zed-editor")
                  `("VK_DRIVER_FILES" ":" prefix
                    (,#$(file-append mesa "/share/vulkan/icd.d/freedreno_icd.aarch64.json"))))))))))
    (native-inputs (list patchelf))
    (inputs (list glibc (list gcc-14 "lib") glib alsa-lib libxcb libx11
                  libxkbcommon wayland vulkan-loader))
    (supported-systems '("aarch64-linux"))
    (home-page "https://zed.dev/")
    (synopsis "Zed editor, built by upstream for Linux ARM64")
    (description "Installs the upstream Zed desktop editor with Guix runtime libraries.")
    (license (list license:gpl3+ license:agpl3+ license:asl2.0))))
