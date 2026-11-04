#!/usr/bin/env bash
# Create a dated folder for a new video.
# Usage: new-project.sh "my video name"
set -euo pipefail
NAME="${1:?usage: new-project.sh \"video name\"}"
SLUG="$(date +%Y-%m-%d)-$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g')"
ROOT="$(cd "$(dirname "$0")/.." && pwd)/projects/$SLUG"
mkdir -p "$ROOT"/{tella,music,sfx,graphics,exports}
cat > "$ROOT/notes.md" <<NOTES
# $NAME

- Tella video ID:
- Intro title / subtitle:
- Music (Epidemic Sound track + ID):
- Outro CTA:
NOTES
echo "$ROOT"
