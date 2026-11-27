#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
mio="$(realpath "$1")"
for asset in xterm.js xterm.css; do
  test -f "$mio/public/mioos/$asset"
  install -m 0644 "$mio/public/mioos/$asset" "$root/public/www/$asset"
done
printf 'MIOOS terminal assets installed. Source revision: '
git -C "$mio" rev-parse HEAD
