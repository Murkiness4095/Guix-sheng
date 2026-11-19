#!/usr/bin/env bash
# Import a store closure saved by scripts/store-cache-export.sh.
# Usage: scripts/store-cache-import.sh DIR
set -euo pipefail
GUIX=${GUIX:-guix}
dir=${1:?usage: $0 DIR}
test -f "$dir/store.nar.zst" || { echo "no store archive in $dir" >&2; exit 1; }
if ! { sudo "$GUIX" archive --authorize < "$dir/signing.pub" &&
       zstd -dc "$dir/store.nar.zst" | "$GUIX" archive --import; }; then
  echo "::warning::cached store import failed; rebuilding from substitutes"
fi
