;; Fixed channels for a standalone sheng configuration.
(use-modules (guix channels))

(list (channel
        (name 'guix)
        (url "https://codeberg.org/guix/guix.git")
        (commit "3c50593f27267dbc5e4e3ec6ff97e7987aff31b7")
        (introduction
         (make-channel-introduction
          "9edb3f66fd807b096b48283debdcddccfea34bad"
          (openpgp-fingerprint
           "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
      (channel
        (name 'midnight)
        (url "https://codeberg.org/stampede/midnight.git")
        (commit "8e0dc3c5d2942ab3ff0b558c2a1a262ac94fec23")
        (introduction
         (make-channel-introduction
          "d97d1568954cfcbf543c9fcdfd5771e2b730ae19"
          (openpgp-fingerprint
           "640A 2C3C E948 22D3 394B 40C3 CAFA EECA 00FF 9B1E"))))
      (channel
        (name 'guix-sheng)
        (url "https://github.com/Murkiness4095/Guix-sheng.git")
        (branch "main")
        (commit "fb31968f552bd89dee6532d9ab86c41570a858f5")))
