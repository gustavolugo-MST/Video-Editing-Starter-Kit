#!/usr/bin/env bash
# Download a file from a URL (Tella export links, Epidemic Sound signed links).
# Usage: fetch.sh URL OUTPUT
set -euo pipefail
URL="${1:?usage: fetch.sh URL OUTPUT}"; OUT="${2:?usage: fetch.sh URL OUTPUT}"
mkdir -p "$(dirname "$OUT")"
curl -fL --retry 3 --progress-bar -o "$OUT" "$URL"
echo "saved -> $OUT"
