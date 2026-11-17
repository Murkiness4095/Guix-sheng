;; Grow the flashed ext4 filesystem to the existing GPT partition boundary.
(define-module (services grow-root)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:export (sheng-grow-root-service))

(define (sheng-grow-root-service root-label)
  (define grow-root
    (program-file
     "sheng-grow-root"
     #~(begin
         (use-modules (ice-9 popen) (ice-9 rdelim))
         (let* ((target (string-append "/dev/disk/by-partlabel/" #$root-label))
                (mount (open-pipe* OPEN_READ #$(file-append util-linux "/bin/findmnt")
                                   "--noheadings" "--output" "SOURCE"
                                   "--types" "ext4" "--options" "rw"
                                   "--mountpoint" "/"))
                (source (read-line mount))
                (status (close-pipe mount)))
           (if (and (zero? status) (string? source)
                    (string-prefix? "/dev/" source)
                    (file-exists? source) (file-exists? target)
                    (string=? (canonicalize-path source) (canonicalize-path target)))
               (exit (status:exit-val
                      (system* #$(file-append e2fsprogs "/sbin/resize2fs") target)))
               (format (current-error-port)
                       "Skipping root expansion: / is not writable ext4 on ~a.~%"
                       target))))))
  (simple-service
   'sheng-grow-root shepherd-root-service-type
   (list (shepherd-service
          (provision '(sheng-grow-root))
          (requirement '(root-file-system udev))
          (documentation "Expand the mounted sheng ext4 root filesystem.")
          (one-shot? #t)
          (start #~(lambda () (zero? (system* #$grow-root))))))))
