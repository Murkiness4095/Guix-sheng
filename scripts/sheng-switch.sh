#!/usr/bin/env bash
# Register an imported sheng system closure as the next Guix generation and
# switch to it, without re-evaluating the configuration.
# Usage: sudo scripts/sheng-switch.sh /gnu/store/...-system
#
# Equivalent to NixOS:
#   nix-env -p /nix/var/nix/profiles/system --set "$candidate"
#   "$candidate/bin/switch-to-configuration" boot
# Requires sheng-extlinux to be visible to Guix's bootloader registry, i.e.
# the guix-sheng channel must be part of the profile running this script.
set -euo pipefail
GUIX=${GUIX:-guix}
profile=/var/guix/profiles/system
candidate=${1:?usage: $0 /gnu/store/...-system}

if [[ $candidate != /gnu/store/*-system ]]; then
  echo "not a system store path: $candidate" >&2
  exit 1
fi
test -x "$candidate/activate" || { echo "missing $candidate/activate" >&2; exit 1; }
test -f "$candidate/parameters" || { echo "missing $candidate/parameters" >&2; exit 1; }

shopt -s nullglob
last=0
for link in "$profile"-*-link; do
  number=${link##*/system-}
  number=${number%-link}
  if [[ $number =~ ^[0-9]+$ ]]; then
    (( number > last )) && last=$number
    if [[ $(readlink -f "$link") == "$candidate" ]]; then
      exec "$GUIX" system switch-generation "$number"
    fi
  fi
done

next=$((last + 1))
ln -s "$candidate" "$profile-$next-link"
"$GUIX" system switch-generation "$next"
