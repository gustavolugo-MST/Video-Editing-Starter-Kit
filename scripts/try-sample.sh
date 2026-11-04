#!/usr/bin/env bash
# Practice run: builds a fake 6-second test clip and runs it through assemble.sh,
# so you can confirm the pipeline works before using real footage.
# Usage: scripts/try-sample.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$HERE/../projects/sample"
mkdir -p "$OUT_DIR"

ffmpeg -y -loglevel error \
  -f lavfi -i "testsrc2=size=1920x1080:rate=30:duration=6" \
  -f lavfi -i "sine=frequency=220:duration=6" \
  -c:v libx264 -pix_fmt yuv420p -c:a aac "$OUT_DIR/test-main.mp4"

"$HERE/assemble.sh" --main "$OUT_DIR/test-main.mp4" --format youtube --out "$OUT_DIR/test-final.mp4"
"$HERE/probe.sh" "$OUT_DIR/test-final.mp4"
echo
echo "Done. Open projects/sample/test-final.mp4 to check it plays."
