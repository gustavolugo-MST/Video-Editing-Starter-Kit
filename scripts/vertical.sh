#!/usr/bin/env bash
# Make a 9:16 (1080x1920) version for Shorts/Reels/TikTok: the full frame sits
# centered over a blurred, zoomed copy of itself. Optionally trim first.
#
# Usage: vertical.sh INPUT OUTPUT [START_SECONDS DURATION_SECONDS]
set -euo pipefail

IN="${1:?usage: vertical.sh INPUT OUTPUT [START DURATION]}"
OUT="${2:?usage: vertical.sh INPUT OUTPUT [START DURATION]}"
TRIM=()
[ -n "${3:-}" ] && TRIM+=(-ss "$3")
[ -n "${4:-}" ] && TRIM+=(-t "$4")

ffmpeg -hide_banner -loglevel error -y ${TRIM[@]+"${TRIM[@]}"} -i "$IN" -filter_complex "\
[0:v]split[a][b];\
[a]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=40,eq=brightness=-0.12[bg];\
[b]scale=1080:-2[fg];\
[bg][fg]overlay=(W-w)/2:(H-h)/2,format=yuv420p[v]" \
  -map "[v]" -map "0:a?" -map_metadata -1 -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 192k -movflags +faststart "$OUT"
echo "vertical -> $OUT"
