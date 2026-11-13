;; 多机部署样板：对应 nixos-sheng 的 flake-parts 多主机写法。
;; 用法：guix deploy deploy.scm
(use-modules (gnu)
             (gnu machine)
             (gnu machine ssh)
             (guix gexp))

(define sheng-os
  (load "system.scm"))

(list
 (machine
  (environment (machine-ssh-configuration
                (host-name "sheng")
                (identity "/home/you/.ssh/id_ed25519")
                (system "aarch64-linux")))
  (configuration sheng-os)))
