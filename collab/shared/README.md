# Shared mechanism

Cross-room shared state, conventions and locks.

- `conventions.md`: communication and evidence rules.
- `state.scm`: shared Guix variables/paths referenced by modules.
- `locks/`: advisory lock files for exclusive resources (serial port, fastboot, device).
- `status.json` (generated): snapshot consumed by workbench.
