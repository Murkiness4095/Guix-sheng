;; channels.scm — Guix channels for sheng (Xiaomi Pad 6S Pro, aarch64).
;; The guix channel uses the GitHub mirror: Savannah's Git endpoint is
;; unreliable from CI ("SSL error: syscall failure").  The mirror carries the
;; same signed commits, so channel authentication still applies.
(list (channel
        (name 'guix)
        (url "https://github.com/guix-mirror/guix.git")
        (branch "master")
        (introduction
         (make-channel-introduction
          "9edb3f66fd807b096b48283debdcddccfea34bad"
          (openpgp-fingerprint
           "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
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
