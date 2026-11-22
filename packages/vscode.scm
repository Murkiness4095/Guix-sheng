(define-module (packages vscode)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages base)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (guix base16)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (sheng-vscode))

(define sheng-vscode
  (package
    (name "visual-studio-code")
    (version "1.147.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://vscode.download.prss.microsoft.com/dbazure/download/stable/8a14f0cc1b08d531eb83255ea3764ae22aa932b5/code-stable-arm64-1794902859.tar.gz")
       (sha256
        (base16-string->bytevector
         "b137f53a29a1debf9fc30027823556863202f94c10d924dd70f2d2370795412d"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:strip-binaries? #f
      #:install-plan #~'(("." "lib/vscode"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'configure-runtime
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((directory (string-append #$output "/lib/vscode"))
                     (loader (search-input-file inputs "/lib/ld-linux-aarch64.so.1"))
                     (rpath (string-join
                             (cons directory
                                   (map (lambda (input)
                                          (string-append (cdr input) "/lib"))
                                        inputs)) ":")))
                (for-each
                 (lambda (file)
                   (when (and (elf-file? file)
                              (zero? (system* "patchelf" "--print-rpath" file)))
                     (when (zero? (system* "patchelf" "--print-interpreter" file))
                       (invoke "patchelf" "--set-interpreter" loader file))
                     (invoke "patchelf" "--set-rpath" rpath file)))
                 (find-files directory ".*"))
                (mkdir-p (string-append #$output "/bin"))
                (call-with-output-file (string-append #$output "/bin/code")
                  (lambda (port)
                    (format port "#!~a~%exec ~a --ozone-platform=wayland --enable-wayland-ime \"$@\"~%"
                            (search-input-file inputs "/bin/sh")
                            (string-append directory "/bin/code"))))
                (chmod (string-append #$output "/bin/code") #o755)
                (mkdir-p (string-append #$output "/share/applications"))
                (call-with-output-file
                    (string-append #$output "/share/applications/code.desktop")
                  (lambda (port)
                    (format port "[Desktop Entry]~%Type=Application~%Name=Visual Studio Code~%Exec=~a/bin/code %F~%Icon=~a/lib/vscode/resources/app/resources/linux/code.png~%Categories=Development;IDE;~%StartupWMClass=Code~%"
                            #$output #$output)))))))))
    (native-inputs (list patchelf))
    (inputs
     (list bash-minimal glibc (list gcc-14 "lib") glib gtk+ at-spi2-core
           alsa-lib cups nss nspr libx11 libxcb libxcomposite libxdamage
           libxext libxfixes libxrandr libxkbcommon libdrm mesa vulkan-loader
           expat fontconfig cairo pango))
    (supported-systems '("aarch64-linux"))
    (home-page "https://code.visualstudio.com/")
    (synopsis "Visual Studio Code for sheng")
    (description "Microsoft's ARM64 editor with Guix runtime libraries and native Wayland input.")
    (license (license:non-copyleft "https://code.visualstudio.com/license"))))
