#!/usr/bin/env bash
# Conform any clip to one spec so clips can be joined losslessly:
# WIDTHxHEIGHT, FPS, H.264 yuv420p, AAC 48 kHz stereo.
# If the clip's shape doesn't match (e.g. 16:9 footage into a 9:16 Reel), it is
# fitted inside the frame over a blurred, zoomed copy of itself instead of black bars.
# Clips with no audio track (e.g. HyperFrames renders) get a silent track.
#
# Usage: conform.sh INPUT OUTPUT [WIDTH HEIGHT FPS]   (default 1920 1080 30)
set -euo pipefail

IN="${1:?usage: conform.sh INPUT OUTPUT [WIDTH HEIGHT FPS]}"
OUT="${2:?usage: conform.sh INPUT OUTPUT [WIDTH HEIGHT FPS]}"
W="${3:-1920}"; H="${4:-1080}"; FPS="${5:-30}"

DIMS="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x "$IN")"
IW="${DIMS%%x*}"; IH="${DIMS##*x}"
SAME_SHAPE="$(awk -v a="$IW" -v b="$IH" -v c="$W" -v d="$H" 'BEGIN { r = (a/b)/(c/d); print (r > 0.99 && r < 1.01) ? 1 : 0 }')"

TAIL="fps=${FPS},format=yuv420p,setsar=1"
if [ "$SAME_SHAPE" = 1 ]; then
  VF="[0:v]scale=${W}:${H},${TAIL}[v]"
else
  VF="[0:v]split[a][b];\
[a]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},gblur=sigma=40,eq=brightness=-0.12[bg];\
[b]scale=${W}:${H}:force_original_aspect_ratio=decrease[fg];\
[bg][fg]overlay=(W-w)/2:(H-h)/2,${TAIL}[v]"
fi
AF="aresample=48000,aformat=sample_fmts=fltp:channel_layouts=stereo"
ENC=(-map_metadata -1 -c:v libx264 -preset "${CONFORM_PRESET:-medium}" -crf "${CONFORM_CRF:-18}" -c:a aac -b:a 192k -ar 48000 -movflags +faststart)

if ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$IN" | grep -q .; then
  ffmpeg -hide_banner -loglevel error -y -i "$IN" \
    -filter_complex "${VF};[0:a]${AF}[a]" -map "[v]" -map "[a]" "${ENC[@]}" "$OUT"
else
  ffmpeg -hide_banner -loglevel error -y -i "$IN" -f lavfi -i "anullsrc=r=48000:cl=stereo" \
    -filter_complex "${VF};[1:a]${AF}[a]" -map "[v]" -map "[a]" -shortest "${ENC[@]}" "$OUT"
fi
echo "conformed -> $OUT"
