#!/usr/bin/env bash
# Export built store closures as one signed nar bundle for the CI cache.
# Usage: scripts/store-cache-export.sh OUTDIR SYSTEM...
set -euo pipefail
GUIX=${GUIX:-guix}
out=${1:?usage: $0 OUTDIR SYSTEM...}
shift
(($#)) || { echo "no system paths" >&2; exit 1; }
mkdir -p "$out"
sudo test -f /etc/guix/signing-key.sec || sudo "$GUIX" archive --generate-key
sudo cat /etc/guix/signing-key.pub > "$out/signing.pub"
"$GUIX" archive --export -r "$@" | zstd -T0 -o "$out/store.nar.zst"
