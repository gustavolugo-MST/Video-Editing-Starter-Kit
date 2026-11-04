#!/usr/bin/env bash
# Fix Tella Studio Sound audio: shift it back in sync and fill its dead silences with faint room tone.
# Studio Sound removes background noise well but gates pauses to digital silence (the voice cuts in and out),
# and its processing lands ~30 ms late.
#
# Usage: scripts/voice-roomtone.sh IN.mp4 OUT.mp4 [SYNC_SHIFT_S] [ROOMTONE_DB_BELOW]
#   IN.mp4             camera file whose audio is Tella Studio Sound (e.g. the joined camera track)
#   SYNC_SHIFT_S       seconds to move the audio earlier (default 0.03)
#   ROOMTONE_DB_BELOW  room tone level below the voice's integrated loudness (default 46 dB, which lands at about
#                      -60 dBFS after assemble.sh brings the video to -14 LUFS)
# Video is copied untouched; output audio is AAC 48 kHz.
set -euo pipefail
IN="${1:?usage: voice-roomtone.sh IN.mp4 OUT.mp4 [SYNC_SHIFT_S] [ROOMTONE_DB_BELOW]}"
OUT="${2:?usage: voice-roomtone.sh IN.mp4 OUT.mp4 [SYNC_SHIFT_S] [ROOMTONE_DB_BELOW]}"
SHIFT="${3:-0.03}"; BELOW="${4:-46}"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

DUR="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$IN")"
ffmpeg -v error -y -i "$IN" -vn -af "atrim=start=${SHIFT},asetpts=PTS-STARTPTS,aresample=48000" -c:a pcm_s24le "$TMP/voice.wav"
L="$(ffmpeg -hide_banner -nostats -i "$TMP/voice.wav" -af ebur128=framelog=quiet -f null - 2>&1 | sed -n 's/^ *I: *\(-*[0-9.]*\) LUFS.*/\1/p' | tail -1)"
# filtered brown noise: amplitude 0.0006 measures -81.2 dBFS RMS; scale to (L - BELOW)
AMP="$(python3 -c "print(round(0.0006 * 10 ** ((${L} - ${BELOW} + 81.18) / 20), 6))")"
VD="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$TMP/voice.wav")"
ffmpeg -v error -y -i "$TMP/voice.wav" \
  -f lavfi -i "anoisesrc=color=brown:amplitude=${AMP}:sample_rate=48000:seed=7,lowpass=f=2500,highpass=f=120" \
  -filter_complex "[1:a]atrim=0:${VD}[rt];[0:a][rt]amix=inputs=2:duration=first:normalize=0,apad=whole_dur=${DUR}[a]" \
  -map "[a]" -c:a pcm_s24le "$TMP/mixed.wav"
ffmpeg -v error -y -i "$IN" -i "$TMP/mixed.wav" -map 0:v -map 1:a -c:v copy -c:a aac -b:a 256k -ar 48000 -shortest "$OUT"
echo "voice ${L} LUFS, room tone ${BELOW} dB below (amp ${AMP}), shifted ${SHIFT}s earlier -> $OUT"
