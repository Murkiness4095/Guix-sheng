(define-module (packages sheng-sddm)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages qt)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:export (sheng-sddm))

(define sheng-sddm
  (package
    (inherit sddm)
    (name "sheng-sddm")
    (arguments
     (substitute-keyword-arguments (package-arguments sddm)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'install 'enable-virtual-keyboard
              (lambda _
                (for-each
                 (lambda (program)
                   (wrap-program program
                     `("QT_PLUGIN_PATH" ":" prefix
                       (,#$(file-append qtvirtualkeyboard "/lib/qt6/plugins")))
                     `("QML_IMPORT_PATH" ":" prefix
                       (,#$(file-append qtvirtualkeyboard "/lib/qt6/qml")))))
                 (find-files (string-append #$output "/bin") "sddm-greeter"))))))))))
