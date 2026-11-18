#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -r -- "$work"' EXIT
revision=af0bf4b1e1c40738db917b04c9c0563b4f718953
expected=/gnu/store/5vcpisacp53afd6a7mjw9vy4alcx08m8-noctalia-greeter-1.7.0-checkout
mkdir "$work/source"
curl --fail --silent --show-error --location --retry 3 \
  "https://codeload.github.com/noctalia-dev/noctalia-greeter/tar.gz/$revision" \
  -o "$work/source.tar.gz"
tar -xzf "$work/source.tar.gz" --strip-components=1 -C "$work/source"
actual=$("${GUIX:-guix}" repl "$repo/scripts/seed-noctalia-greeter.scm" "$work/source")
if [[ "$actual" != "$expected" ]]; then
  echo "Unexpected noctalia-greeter source store path: $actual" >&2
  exit 1
fi
