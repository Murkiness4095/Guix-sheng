(use-modules (gnu build image)
             (ice-9 match))

(match (cdr (command-line))
  ((prefix graph graphs ...)
   (for-each (lambda (file)
               ((@@ (gnu build image) register-closure)
                prefix file #:wal-mode? #f))
             (cons graph graphs))))
