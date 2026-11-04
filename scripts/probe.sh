#!/usr/bin/env bash
# Quick report on a media file: duration, resolution, fps, codecs, loudness.
# Usage: probe.sh FILE
set -euo pipefail
F="${1:?usage: probe.sh FILE}"
ffprobe -v error -show_entries format=duration:stream=codec_type,codec_name,width,height,r_frame_rate,sample_rate,channels \
  -of default=noprint_wrappers=1 "$F"
if ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$F" | grep -q .; then
  ffmpeg -hide_banner -nostats -i "$F" -af ebur128=peak=true -f null - 2>&1 \
    | awk '/Summary:/{s=1} s && /I:|LRA:|Peak:/{gsub(/^ +/,""); print}'
fi
