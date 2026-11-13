# Working on Guix-sheng

- Read README.md, TODO.md, docs/HANDOVER.md first.
- Collaboration scaffolding lives in `collab/`; system declarations stay at the
  repo root (`images/`, `packages/`, `modules/`, `services/`).
- Rooms in `collab/rooms/*` are append-only per-function channels; post
  evidence-backed updates.
- Shared rules in `collab/shared/conventions.md`.
- Regenerate workbench: `scripts/workbench` (use `--watch` for live updates).
- Do not silently upgrade board dependencies; pin commits and record evidence.
