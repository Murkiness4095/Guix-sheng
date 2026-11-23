#!/usr/bin/env bash
# Retry once if a failed substitute leaves an unregistered Qt debug output.
set -euo pipefail
guix_program=${GUIX:-guix}
log=$(mktemp)
trap 'rm -f -- "$log"' EXIT

exec 3>&1
if "$guix_program" "$@" 2>&1 >&3 | tee "$log" >&2; then
  exit 0
fi

path=$(sed -nE 's@.*mkdir: File exists: "(/gnu/store/[a-z0-9]{32}-qtbase-[0-9.]+-debug)".*@\1@p' "$log" | tail -n 1)
if [[ ${GITHUB_ACTIONS:-} != true || -z $path || ! -d $path ]]; then
  exit 1
fi
if "$guix_program" gc --references "$path" >/dev/null 2>&1; then
  echo "Refusing to remove registered store path: $path" >&2
  exit 1
fi
sudo rm -rf -- "$path"
"$guix_program" "$@"
