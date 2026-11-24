;;; sheng peripheral package recipes, ported from nixos-sheng.
(define-module (packages peripherals)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages python)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages xdisorg)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system linux-module)
  #:use-module (packages firmware)
  #:use-module (packages kernel)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (alsa-ucm-sheng sheng-fastrpc sheng-libssc sheng-iio-sensor-proxy
            sheng-charger-mode sheng-devauth sheng-fingerprint
            sheng-keyboard-helper sheng-mipps-auth sheng-pen-status
            sheng-sensors sheng-thp sheng-mdss-test-module))

(define* (github-source owner repo revision hash #:optional (patches '()))
  (origin
    (method url-fetch)
    (uri (string-append "https://codeload.github.com/" owner "/" repo
                        "/tar.gz/" revision))
    (file-name (string-append repo "-" revision ".tar.gz"))
    (sha256 (base32 hash))
    (patches patches)))

(define (flat-source url name hash)
  (origin
    (method url-fetch)
    (uri url)
    (file-name name)
    (sha256 (base32 hash))))

(define alsa-ucm-sheng
  (package
    (name "alsa-ucm-sheng")
    (version "1")
    (source (flat-source
             "https://gitlab.postmarketos.org/alghiffaryfa19/pmaports/-/raw/sheng/device/testing/device-xiaomi-sheng/HiFi.conf"
             "HiFi.conf" "10fxwmn1i9zmjacawl9yxh8105xjliy8675i5di604jhpvv4z7lg"))
    (build-system trivial-build-system)
    (arguments
     (list #:modules '((guix build utils))
           #:builder
           #~(begin
               (use-modules (guix build utils))
               (let* ((ucm (string-append #$output "/share/alsa/ucm2"))
                      (profile (string-append ucm "/Xiaomi/sheng"))
                      (aliases (string-append ucm "/conf.d/sm8550")))
                 (mkdir-p profile)
                 (mkdir-p aliases)
                 (copy-file #$source (string-append profile "/HiFi.conf"))
                 (copy-file
                  #$(local-file "firmware/alsa-ucm-sheng/Xiaomi-Pad6SPro.conf")
                  (string-append profile "/Xiaomi-Pad6SPro.conf"))
                 (symlink "../../Xiaomi/sheng/Xiaomi-Pad6SPro.conf"
                          (string-append aliases "/Xiaomi-Pad6SPro.conf"))))))
    (home-page "https://gitlab.postmarketos.org/alghiffaryfa19/pmaports")
    (synopsis "ALSA UCM profile for Xiaomi Pad 6S Pro")
    (description "Installs the WCD938X mixer and routing profile for sheng.")
    (license license:expat)))

(define sheng-fastrpc
  (package
    (name "sheng-fastrpc")
    (version "1.0.2")
    (source (github-source "qualcomm" "fastrpc" "v1.0.2" "1jn85k11yicw3gw9y3zcczgn9jax2rh1yahv9irm5xmn0qh8w60d"))
    (build-system gnu-build-system)
    (arguments
     (list #:configure-flags #~'("--with-config-base-dir=/var/lib/qcom")
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'install 'install-sensor-daemon
                 (lambda _
                   (install-file "src/adsprpcd" (string-append #$output "/bin"))
                   (for-each
                    (lambda (program)
                      (invoke "patchelf" "--add-rpath" (string-append #$output "/lib")
                              (string-append #$output "/bin/" program)))
                    '("adsprpcd" "cdsprpcd"))
                   (let ((test-program (string-append #$output "/bin/fastrpc_test"))
                         (test-data (string-append #$output "/share/fastrpc_test")))
                     (when (file-exists? test-program) (delete-file test-program))
                     (when (file-exists? test-data) (delete-file-recursively test-data))
                   (let ((test-libraries (string-append #$output "/lib/fastrpc_test")))
                     (when (file-exists? test-libraries)
                       (delete-file-recursively test-libraries)))))))))
    (native-inputs (list autoconf automake libtool pkg-config patchelf))
    (inputs (list libyaml))
    (home-page "https://github.com/qualcomm/fastrpc")
    (synopsis "Qualcomm DSP RPC userspace and sensor daemon")
    (description "Builds the FastRPC userspace and daemons for the sheng DSP.")
    (license license:bsd-3)))

(define sheng-libssc
  (package
    (name "sheng-libssc")
    (version "0.4.4")
    ;; Exact Codeberg archive for 033e2a32095c024d6dbdfb1d4ae1db4a94be32f1.
    (source (local-file "firmware/libssc-033e2a3.tar.gz"))
    (build-system meson-build-system)
    ;; Upstream check launches an SSC mock server over a host QRTR socket.
    (arguments
     (list #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'apply-qmi-retry-patch
                 (lambda _
                   (invoke "patch" "-p1" "-i"
                           #$(local-file "firmware/wait-for-qmi-service.patch")))))))
    (native-inputs (list pkg-config protobuf python))
    (inputs (list glib))
    (propagated-inputs (list protobuf-c libqmi))
    (home-page "https://codeberg.org/DylanVanAssche/libssc")
    (synopsis "Qualcomm Sensor Core client library")
    (description "Provides the SSC client and retries lookup of the sensor service.")
    (license license:gpl3)))

(define sheng-iio-sensor-proxy
  (package
    (name "sheng-iio-sensor-proxy")
    (version "3.9")
    (source
     (origin
       (method url-fetch)
       (uri "https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/-/archive/3.9/iio-sensor-proxy-3.9.tar.gz")
       (sha256 (base32 "1r4schhhx5mdzcp37bqcciqhmsanqxy3pla2lb1jv9fgglqdspmg"))
       (patches
        (list (local-file "firmware/iio-sensor-proxy/0104-sheng-discovery-3.9.patch")))))
    (build-system meson-build-system)
    (arguments
     (list #:configure-flags
           #~(list "-Dssc-support=enabled"
                   (string-append "-Dsystemdsystemunitdir=" #$output "/lib/systemd/system")
                   (string-append "-Dudevrulesdir=" #$output "/lib/udev/rules.d"))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'install-polkit-policy-in-output
                 (lambda _
                   (substitute* "meson.build"
                     (("polkit_gobject_dep.get_pkgconfig_variable\\('policydir'\\)")
                      "get_option('prefix') / 'share' / 'polkit-1' / 'actions'")))))))
    (native-inputs (list pkg-config (list glib "bin")))
    (inputs (list glib libgudev eudev polkit sheng-libssc))
    (home-page "https://gitlab.freedesktop.org/hadess/iio-sensor-proxy")
    (synopsis "IIO sensor proxy with sheng SSC support")
    (description "Exposes sheng accelerometer, light and proximity sensor readings over D-Bus.")
    (license license:gpl3)))

(define sheng-sensors
  (package
    (name "sheng-sensors")
    (version "20240917")
    (source (github-source "alghiffaryfa19" "sheng-sensors-file"
                           "199754bb37ae6d4706bd8d4b23e9e6fec2d959cc"
                           "0mdxkq7l0i008l6s9afqj0vsclrvw3kdy63ha4if7kjhgvccygp1"))
    (build-system copy-build-system)
    (arguments
     (list #:install-plan #~'(("usr/share/qcom" "share/qcom"))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'set-registry-path
                 (lambda _
                   (substitute* "usr/share/qcom/sm8550/Xiaomi/sheng/vendor/etc/sensors/sns_reg_config"
                     (("/usr/share/qcom") "/var/lib/qcom"))))
               (add-after 'install 'install-udev-rule
                 (lambda _
                   (let ((rules (string-append #$output "/lib/udev/rules.d")))
                     (mkdir-p rules)
                     (copy-file #$(local-file "firmware/sheng-sensors/81-sheng-ssc-sensors.rules")
                                (string-append rules "/81-sheng-ssc-sensors.rules"))))))))
    (home-page "https://github.com/alghiffaryfa19/sheng-sensors-file")
    (synopsis "Sensor registry files for sheng")
    (description "Installs Qualcomm SSC registry data and its ADSP discovery rule.")
    (license #f)))

(define sheng-devauth
  (package
    (name "sheng-devauth")
    (version "1.0")
    (source (github-source "ianchb" "sheng_devauth"
                           "bac03b5bcfefa1467ebad490edd910a6cef8a207"
                           "1d5z4a3qsrlr5rkalhrqmfxjprz8rnpa48dwiiwxyzb07hkcaj5w"))
    (build-system gnu-build-system)
    (arguments
     (list #:tests? #f
           #:make-flags #~'("CC=gcc")
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-after 'unpack 'set-firmware-location
                 (lambda _
                   (let ((firmware #$(file-append sheng-firmware
                                                 "/lib/firmware/qcom/sm8550/sheng")))
                     (unless (file-exists? (string-append firmware "/devauth.mbn"))
                       (error "Missing sheng keyboard authentication firmware"))
                     (substitute* "main.c"
                       (("/usr/lib/firmware/qcom/sm8550/sheng") firmware)))))
               (replace 'install
                 (lambda _
                   (install-file "xiaomi_devauth" (string-append #$output "/bin")))))))
    (home-page "https://github.com/ianchb/sheng_devauth")
    (synopsis "Xiaomi keyboard authentication daemon")
    (description "Authenticates the detachable keyboard on sheng.")
    (license license:bsd-3)))

(define* (ssc-make-arguments #:key keyboard?)
  (list #:tests? #f
        #:make-flags #~'("CC=gcc")
        #:phases
        #~(modify-phases %standard-phases
            (delete 'configure)
            (add-after 'unpack 'use-store-libssc
              (lambda _
                (substitute* "Makefile"
                  (("-Werror") "")
                  (("/usr/include/libssc") #$(file-append sheng-libssc "/include/libssc")))))
            (replace 'install
              (lambda _
                (use-modules (ice-9 ftw))
                (if #$keyboard?
                    (begin
                      (invoke "make" "install" (string-append "DESTDIR=" #$output))
                      (for-each
                       (lambda (entry)
                         (rename-file entry
                                      (string-append #$output "/" (basename entry))))
                       (map (lambda (name) (string-append #$output "/usr/" name))
                            (scandir (string-append #$output "/usr")
                                     (lambda (name) (not (member name '("." "..")))))))
                      (rmdir (string-append #$output "/usr")))
                    (invoke "make" "install"
                            (string-append "PREFIX=" #$output) "DESTDIR=")))))))

(define sheng-keyboard-helper
  (package
    (name "sheng-keyboard-helper")
    (version "0.2.0")
    (source (github-source "ianchb" "xiaomi-sheng-keyboard-helper"
                           "3bb9aada8814e81a5c22de5d1e5dd70f4b99183e"
                           "0265achscncy2yf5fqj81pn94zlq68c6gbkrvfbvwzgai0333iw7"))
    (build-system gnu-build-system)
    (arguments (ssc-make-arguments #:keyboard? #t))
    (native-inputs (list pkg-config))
    (inputs (list glib sheng-libssc))
    (home-page "https://github.com/ianchb/xiaomi-sheng-keyboard-helper")
    (synopsis "Fold-angle and microphone LED helper for the sheng keyboard")
    (description "Synchronizes the detachable keyboard state with the active session.")
    (license license:asl2.0)))

(define sheng-thp
  (package
    (name "sheng-thp")
    (version "0.3.9")
    (source (github-source "ianchb" "xiaomi-sheng-thp"
                           "34046210932d654a4c0df0121ecc31c008f8148c"
                           "0idkp3qmkw7dzl0x4x4lnxm4mi86ghxsvs40qzzfpc4na2k1n7my"))
    (build-system gnu-build-system)
    (arguments (ssc-make-arguments))
    (native-inputs (list pkg-config))
    (inputs (list glib sheng-libssc))
    (home-page "https://github.com/ianchb/xiaomi-sheng-thp")
    (synopsis "NT36532E userspace touch host processor")
    (description "Translates raw touch and stylus frames to input events on sheng.")
    (license license:asl2.0)))

(define sheng-charger-mode
  (package
    (name "sheng-charger-mode")
    (version "0.1")
    (source (github-source "ianchb" "xiaomi-charger-mode"
                           "0c00fcd2cb064f563f44babb345c1dffecf2ada2"
                           "001plppv95jsa2blxh91sx8ccxiillxacwpgisp6cifa59pl6js7"))
    (build-system copy-build-system)
    (arguments
     (list #:strip-binaries? #f
           #:install-plan #~'(("xiaomi-charger-mode" "libexec/"))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'install 'make-charger-script-executable
                 (lambda _
                   (chmod (string-append #$output "/libexec/xiaomi-charger-mode")
                          #o755))))))
    (inputs (list python))
    (supported-systems '("aarch64-linux"))
    (home-page "https://github.com/ianchb/xiaomi-charger-mode")
    (synopsis "Charger-mode display for sheng")
    (description "Installs the upstream Python framebuffer charging screen.")
    (license #f)))

(define sheng-mipps-auth
  (package
    (name "sheng-mipps-auth")
    (version "0.21")
    (source (github-source "ianchb" "xiaomi-mipps-auth"
                           "9176efbdf276b874fc0a97912a914449a88155fb"
                           "1g43svdx8sb77mp2dhzvacvxqj8lmcq05b6xv95bczmq4sjjinq7"
                           (list (local-file "firmware/sheng-mipps-auth/skip-unsupported-before-role-swap.patch")
                                 (local-file "firmware/sheng-mipps-auth/shepherd-trigger.patch"))))
    (build-system copy-build-system)
    (arguments
     (list #:install-plan
           #~'(("xiaomi-mipps-auth" "libexec/")
               ("90-xiaomi-mipps-auth.rules" "lib/udev/rules.d/"))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'install 'wrap-authentication-helper
                 (lambda _
                   (let ((program (string-append #$output "/libexec/xiaomi-mipps-auth")))
                     (chmod program #o755)
                     (wrap-program program
                       `("PATH" ":" prefix
                         (,#$(file-append python "/bin")
                          ,(string-append #$glib:bin "/bin"))))
                     (substitute* (string-append #$output "/lib/udev/rules.d/90-xiaomi-mipps-auth.rules")
                       (("/usr/libexec/xiaomi-mipps-auth") program))))))))
    (inputs (list glib python))
    (home-page "https://github.com/ianchb/xiaomi-mipps-auth")
    (synopsis "Xiaomi MiPPS charging authentication helper")
    (description "Installs the charger authentication script and its udev rule.")
    (license #f)))

(define sheng-pen-status
  (package
    (name "sheng-pen-status")
    (version "0.2.3")
    (source (github-source "ianchb" "xiaomi-pen-status"
                           "fcf349109d2e69aedf7170479cc38b102ba1d4c0"
                           "1qkc69y9gpxn7dhlxxa8c63q0l4hw1wjqmd5qvw80a5mq92f68a1"))
    (build-system gnu-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
               (replace 'configure
                 (lambda _
                   (substitute* "main.cpp"
                     (("#include <QFile>") "#include <QFile>\n#include <unistd.h>")
                     (("const QString serverName = QStringLiteral\\(\"xiaomi-pen-status\"\\);")
                      "const QString serverName = QStringLiteral(\"xiaomi-pen-status-\") + QString::number(static_cast<qulonglong>(::getuid()));")
                     (("QLockFile lockFile\\(QDir::temp\\(\\).absoluteFilePath")
                      "QLockFile lockFile(QDir(qEnvironmentVariable(\"XDG_RUNTIME_DIR\", QDir::tempPath())).absoluteFilePath"))
                   (invoke "qmake" "xiaomi-pen-status.pro")))
               (add-after 'build 'build-cli
                 (lambda _
                   (invoke "g++" "-x" "c++" "-std=c++17" "-O2"
                           #$(flat-source
                              "https://raw.githubusercontent.com/ianchb/xiaomi-pen-status/8b0ff3eb143b84541cc1e55ea9cdd3a723256021/xiaomi-pen-status-cli.cpp"
                              "xiaomi-pen-status-cli.cpp" "144x7sscxp0adzzmjj7zlbigyjbgh20mmil0qpp4lvaflyjfalyc")
                           "-o" "xiaomi-pen-status-cli")))
               (replace 'install
                 (lambda _
                   (for-each
                    (lambda (entry)
                      (install-file (car entry) (string-append #$output (cdr entry))))
                    '(("xiaomi-pen-status" . "/bin")
                      ("xiaomi-pen-status-cli" . "/bin")
                      ("xiaomi-pen-status.desktop" . "/share/applications")
                      ("xiaomi-pen-status.svg" . "/share/icons/hicolor/scalable/apps")))
                   (let ((directory (string-append #$output "/etc/xdg/autostart")))
                     (install-file "xiaomi-pen-status.desktop" directory)
                     (substitute* (string-append directory "/xiaomi-pen-status.desktop")
                       (("^Exec=.*")
                        (string-append "Exec=" #$output "/bin/xiaomi-pen-status\n")))))))))
    (native-inputs (list pkg-config))
    (inputs (list qtbase qtsvg))
    (home-page "https://github.com/ianchb/xiaomi-pen-status")
    (synopsis "Xiaomi Focus Pen status utility")
    (description "Installs a Qt tray application and command-line stylus utility.")
    (license license:gpl2)))

(define sheng-fingerprint
  (package
    (name "sheng-fingerprint")
    (version "0.1.4")
    (source (github-source "ianchb" "xiaomi-sheng-fingerprint"
                           "76e7301163b0e708f609c9864b3e5833e9f57402"
                           "0y4jmr3fd166j3fcg7swbwqxi2v3fyj07qwkhmjfyg2lyxs4plwb"))
    (build-system gnu-build-system)
    (arguments
     (list #:tests? #f
           #:strip-binaries? #f
           #:phases
           #~(modify-phases %standard-phases
               (delete 'configure)
               (add-after 'unpack 'verify-upstream-runtime
                 (lambda _
                   (invoke "sha256sum" "-c" "prebuilt/aarch64/SHA256SUMS")))
               (replace 'build
                 (lambda _
                   (setenv "LIBFPRINT_TARBALL"
                           #$(flat-source
                              "https://deb.debian.org/debian/pool/main/libf/libfprint/libfprint_1.94.10.orig.tar.xz"
                              "libfprint_1.94.10.orig.tar.xz" "0ljb92qlpxzmkawmbfsz720v4jnyxim77dbdlwmrhi3qpq42fn7z"))
                   (setenv "CC" "gcc")
                   (let ((backend (string-append (getcwd) "/build/native/backend"))
                         (libfprint (string-append (getcwd) "/build/native/libfprint")))
                     (invoke "sh" "scripts/build-backend.sh" backend)
                     (setenv "LD_LIBRARY_PATH" backend)
                     (invoke "sh" "scripts/build-libfprint.sh" backend libfprint)
                     (unsetenv "LD_LIBRARY_PATH"))))
               (replace 'install
                 (lambda* (#:key inputs #:allow-other-keys)
                   (let* ((fp (string-append #$output "/lib/xiaomi-sheng-fingerprint"))
                          (listeners (string-append #$output "/lib/qtee-listeners"))
                          (libexec (string-append #$output "/libexec"))
                          (glibc-lib (dirname (search-input-file inputs
                                                                "/lib/ld-linux-aarch64.so.1"))))
                     (install-file "build/native/libfprint/libfprint-2.so.2.0.0" fp)
                     (install-file "build/native/backend/libfpc1553-qtee.so" fp)
                     (symlink "libfprint-2.so.2.0.0" (string-append fp "/libfprint-2.so.2"))
                     (symlink "libfprint-2.so.2" (string-append fp "/libfprint-2.so"))
                     (install-file "prebuilt/aarch64/qteesupplicant" libexec)
                     (install-file "prebuilt/aarch64/sfs_config" libexec)
                     (rename-file (string-append libexec "/sfs_config")
                                  (string-append libexec "/fpc-sfs-config"))
                     (for-each
                      (lambda (program)
                        (invoke "patchelf" "--set-interpreter"
                                (string-append glibc-lib "/ld-linux-aarch64.so.1") program)
                        (invoke "patchelf" "--add-rpath"
                                (string-append glibc-lib ":" listeners) program))
                      (list (string-append libexec "/qteesupplicant")))
                     (for-each
                      (lambda (listener)
                        (let ((name (basename listener)))
                          (install-file listener listeners)
                          (invoke "patchelf" "--add-rpath" glibc-lib
                                  (string-append listeners "/" name))
                          (symlink name
                                   (string-append listeners "/"
                                                  (substring name 0 (- (string-length name) 4))))))
                      (find-files "prebuilt/aarch64/qtee-listeners" "\\.so\\.1\\.0\\.0$"))
                     (invoke "patchelf" "--add-rpath"
                             (string-join (map (lambda (package)
                                                 (string-append package "/lib"))
                                               (list #$glib #$gusb #$nss #$pixman))
                                          ":")
                             (string-append fp "/libfprint-2.so.2.0.0"))
                     (install-file "udev/99-qcomtee-fpc.rules"
                                   (string-append #$output "/lib/udev/rules.d"))))))))
    (native-inputs (list meson ninja patchelf pkg-config xz (list glib "bin")))
    (inputs (list glib glibc gusb nss pixman))
    (supported-systems '("aarch64-linux"))
    (home-page "https://github.com/ianchb/xiaomi-sheng-fingerprint")
    (synopsis "FPC1553 fingerprint backend and Qualcomm TEE runtime")
    (description "Builds the sheng libfprint backend and installs its QTEE runtime.")
    (license (list license:asl2.0 license:lgpl2.1+))))

(define sheng-mdss-test-module
  (package
    (name "sheng-mdss-test-module")
    (version "0.1.0")
    (source (local-file "kernel/mdss-test-module" #:recursive? #t))
    (build-system linux-module-build-system)
    (arguments (list #:linux linux-sheng #:tests? #f))
    (supported-systems '("aarch64-linux"))
    (home-page "https://github.com/Murkiness4095/nixos-sheng")
    (synopsis "Sheng MDSS and DSI diagnostic modules")
    (description "Builds the optional MDSS and DSI laboratory modules against linux-sheng.")
    (license license:gpl2)))
