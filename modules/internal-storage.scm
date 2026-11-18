(define-module (modules internal-storage)
  #:use-module (gnu services base)
  #:export (sheng-internal-storage))
(define (sheng-internal-storage)
  (udev-rules-service
   'sheng-internal-storage
   (udev-rule
    "90-sheng-internal-storage.rules"
    "SUBSYSTEM==\"block\", ENV{DEVTYPE}==\"partition\", KERNELS==\"1d84000.ufshc\", ENV{ID_PART_ENTRY_NAME}==\"modem_a|modem_b|bluetooth_a|bluetooth_b|dsp_a|dsp_b|logfs|LOGFS|persist|metadata|rescue|qmcs\", ENV{UDISKS_IGNORE}=\"1\"\n")))
