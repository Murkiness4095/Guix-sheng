;; channels.scm — Guix channels for sheng (Xiaomi Pad 6S Pro, aarch64).
;; Pin commits deliberately; record evidence when updating.
(list (channel
        (name 'guix)
        (url "https://git.savannah.gnu.org/git/guix.git")
        (branch "master"))
      ;; Third-party channel providing noctalia and noctalia-greeter.
      (channel
        (name 'midnight)
        (url "https://codeberg.org/stampede/midnight.git")
        (branch "main")
        (introduction
         (make-channel-introduction
          "d97d1568954cfcbf543c9fcdfd5771e2b730ae19"
          (openpgp-fingerprint
           "640A 2C3C E948 22D3 394B 40C3 CAFA EECA 00FF 9B1E")))))
