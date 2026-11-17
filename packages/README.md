# Sheng packages

`kernel.scm`, `u-boot.scm`, and `firmware.scm` provide the board's boot
components. `peripherals.scm` contains the Scheme ports of the old Nix
recipes from `eb1826e`. The original firmware-blob recipe is covered by
`sheng-firmware`.

Build a peripheral from the repository root in CI or the isolated build
environment. For example:

```sh
guix build -L . -e '(@ (packages peripherals) sheng-thp)'
```

The peripheral package workflow validates the recipes independently from the
root images. Shepherd services, image integration, and hardware validation
are pending. Systemd unit files from the Nix reference remain available
in Git history for translating service dependencies and startup commands.
