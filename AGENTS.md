# Working on Guix-sheng

- Read README.md, TODO.md, docs/HANDOVER.md first.
- System declarations live at the repo root: `images/`, `packages/`, `modules/`, `services/`.
- Do not silently upgrade board dependencies; pin commits and record evidence.
- Build-time identity: CI writes `images/settings.scm` from workflow inputs
  (`desktop_username`, `desktop_password`); local builds fall back to `sheng`.
