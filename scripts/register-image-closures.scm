(use-modules (guix build store-copy)
             (guix store database)
             (ice-9 match))

(match (cdr (command-line))
  ((prefix graph graphs ...)
   (with-database (store-database-file #:prefix prefix) db
     #:wal-mode? #f
     (for-each (lambda (file)
                 (register-items db (call-with-input-file file read-reference-graph)
                                 #:prefix prefix
                                 #:registration-time 0))
               (cons graph graphs)))))
