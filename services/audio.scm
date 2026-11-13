;; services/audio.scm — port of nixos-sheng modules/audio.nix
(define-module (services audio)
  #:use-module (gnu services)
  #:export (sheng-audio-service-type))
(define sheng-audio-service-type
  (service-type
    (name 'sheng-audio)
    (extensions '())
    (default-value #f)
    (description "Apply sheng HiFi UCM verb and WirePlumber UCM config (skeleton).")))
