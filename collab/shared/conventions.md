# Shared conventions

1. One change at a time per device-facing resource; take the lock in `shared/locks/`.
2. Record source commit, CI run, system path before claiming verification.
3. Build success != peripheral works; scope claims to measured interaction.
4. Keep Linux-root and Android-root paths distinct; never erase userdata unintentionally.
5. Private keys, Wi-Fi profiles, backups stay out of Git.
