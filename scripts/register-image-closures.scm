(use-modules (guix build store-copy)
             (guix store database)
             (ice-9 match)
             (srfi srfi-19))

(match (cdr (command-line))
  ((prefix graph graphs ...)
   (with-database (store-database-file #:prefix prefix) db
     #:wal-mode? #f
     (for-each (lambda (file)
                 (register-items db (call-with-input-file file read-reference-graph)
                                 #:prefix prefix
                                 #:registration-time
                                 (make-date 0 0 0 0 1 1 1970 0)))
               (cons graph graphs)))))
