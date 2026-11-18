(use-modules (guix store))

(with-store store
  (display (add-to-store store "noctalia-greeter-1.7.0-checkout"
                         #t "sha256" (cadr (command-line))))
  (newline))
