#!/usr/bin/env bash
# Build the final video: [intro] + main + [outro], with optional background
# music that ducks automatically under speech, loudness-normalized for YouTube.
#
# Usage:
#   assemble.sh --main tella.mp4 [--intro intro.mp4] [--outro outro.mp4] \
#               [--music track.wav] [--music-db -18] [--lufs -14] \
#               [--format youtube|reels|feed|square] --out final.mp4
#
#   --format    youtube 1920x1080 (default) | reels 1080x1920 | feed 1080x1350 | square 1080x1080
#   --music-db  music level before ducking (default -18 dB; lower = quieter)
#   --lufs      integrated loudness target (default -14, YouTube/Spotify standard)
set -euo pipefail

INTRO=""; MAIN=""; OUTRO=""; MUSIC=""; OUT=""; MUSIC_DB="-18"; LUFS="-14"; FORMAT="youtube"
while [ $# -gt 0 ]; do
  case "$1" in
    --intro) INTRO="$2"; shift 2 ;;
    --main) MAIN="$2"; shift 2 ;;
    --outro) OUTRO="$2"; shift 2 ;;
    --music) MUSIC="$2"; shift 2 ;;
    --music-db) MUSIC_DB="$2"; shift 2 ;;
    --lufs) LUFS="$2"; shift 2 ;;
    --format) FORMAT="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done
[ -n "$MAIN" ] && [ -n "$OUT" ] || { echo "need --main and --out (see --help)" >&2; exit 1; }

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/formats.sh"
format_dims "$FORMAT"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
LIST="$TMP/list.txt"; : > "$LIST"

n=0
for clip in "$INTRO" "$MAIN" "$OUTRO"; do
  [ -n "$clip" ] || continue
  n=$((n + 1))
  "$HERE/conform.sh" "$clip" "$TMP/part$n.mp4" "$W" "$H" 30 >/dev/null
  echo "file '$TMP/part$n.mp4'" >> "$LIST"
done
echo "joining $n clip(s) at ${W}x${H} ($FORMAT)..."
ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i "$LIST" -c copy "$TMP/joined.mp4"

DUR="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$TMP/joined.mp4")"
FADE_START="$(awk -v d="$DUR" 'BEGIN { s = d - 3; if (s < 0) s = 0; print s }')"
mkdir -p "$(dirname "$OUT")"

# 1) Build the audio mix (voice + ducked music bed) as a lossless WAV.
if [ -n "$MUSIC" ]; then
  echo "mixing music (ducked under voice)..."
  ffmpeg -hide_banner -loglevel error -y -i "$TMP/joined.mp4" -stream_loop -1 -i "$MUSIC" \
    -filter_complex "\
[0:a]asplit=2[voice][key];\
[1:a]aresample=48000,aformat=sample_fmts=fltp:channel_layouts=stereo,volume=${MUSIC_DB}dB,\
atrim=0:${DUR},afade=t=in:d=1,afade=t=out:st=${FADE_START}:d=3[bed];\
[bed][key]sidechaincompress=threshold=0.015:ratio=12:attack=15:release=450[ducked];\
[voice][ducked]amix=inputs=2:duration=first:normalize=0[a]" \
    -map "[a]" -c:a pcm_s24le "$TMP/mix.wav"
else
  ffmpeg -hide_banner -loglevel error -y -i "$TMP/joined.mp4" -vn -c:a pcm_s24le "$TMP/mix.wav"
fi

# 2) Loudness: measure once, apply ONE fixed gain to reach the target, then a true-peak limiter that only
#    touches the few sharp peaks. (loudnorm's own "linear" mode silently falls back to dynamic normalization
#    when the gain would push peaks over its TP limit, which pumps the voice up and down. Avoid that.)
echo "normalizing audio to ${LUFS} LUFS..."
STATS="$(ffmpeg -hide_banner -nostats -i "$TMP/mix.wav" -af "ebur128=framelog=quiet" -f null - 2>&1)"
INPUT_I="$(echo "$STATS" | sed -n 's/^ *I: *\(-*[0-9.]*\) LUFS.*/\1/p' | tail -1)"
GAIN="$(python3 -c "print(round(${LUFS} - (${INPUT_I}), 2))")"
echo "  measured ${INPUT_I} LUFS, gain ${GAIN} dB"
LN="volume=${GAIN}dB,alimiter=limit=0.79:attack=5:release=80:level=disabled:asc=1,aresample=48000"

ffmpeg -hide_banner -loglevel error -y -i "$TMP/joined.mp4" -i "$TMP/mix.wav" \
  -map 0:v -map 1:a -af "$LN" -c:v copy -c:a aac -b:a 192k -ar 48000 -movflags +faststart "$OUT"
echo "done -> $OUT ($(printf '%.1f' "$DUR")s)"
