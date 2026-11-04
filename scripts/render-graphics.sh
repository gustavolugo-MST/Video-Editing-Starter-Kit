#!/usr/bin/env bash
# Render the HyperFrames intro or outro at any platform size.
# The templates are authored at 1920x1080; this renders a resized copy.
#
# Usage: render-graphics.sh FORMAT intro|outro OUTPUT ['{"title":"..."}']
#   FORMAT: youtube (1920x1080) | reels (1080x1920) | feed (1080x1350) | square (1080x1080)
set -euo pipefail

FORMAT="${1:?usage: render-graphics.sh FORMAT intro|outro OUTPUT [VARIABLES_JSON]}"
WHICH="${2:?usage: render-graphics.sh FORMAT intro|outro OUTPUT [VARIABLES_JSON]}"
OUT="${3:?usage: render-graphics.sh FORMAT intro|outro OUTPUT [VARIABLES_JSON]}"
VARS="${4:-}"

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/formats.sh"
format_dims "$FORMAT"

case "$WHICH" in
  intro) COMP="index.html" ;;
  outro) COMP="compositions/outro.html" ;;
  *) echo "second argument must be intro or outro" >&2; exit 1 ;;
esac

SRC="$HERE/../graphics"
HF_VERSION="$(sed -n 's/.*hyperframes@\([0-9.]*\).*/\1/p' "$SRC/package.json" | head -1)"
case "$OUT" in /*) ;; *) OUT="$PWD/$OUT" ;; esac
mkdir -p "$(dirname "$OUT")"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cp -R "$SRC/index.html" "$SRC/compositions" "$SRC/hyperframes.json" "$SRC/meta.json" "$SRC/package.json" "$TMP/"
for f in "$TMP/index.html" "$TMP"/compositions/*.html; do
  sed -i '' -e "s/1920/__W__/g; s/1080/__H__/g; s/__W__/$W/g; s/__H__/$H/g" \
            -e "s/data-resolution=\"[a-z-]*\"/data-resolution=\"$RES\"/" "$f"
done

cd "$TMP"
ARGS=(-o "$OUT" --quiet)
[ "$COMP" != "index.html" ] && ARGS+=(-c "$COMP")
[ -n "$VARS" ] && ARGS+=(--variables "$VARS")
if ! npx --yes "hyperframes@${HF_VERSION:-latest}" render "${ARGS[@]}" > "$TMP/render.log" 2>&1; then
  cat "$TMP/render.log" >&2; exit 1
fi
echo "rendered $WHICH ($FORMAT ${W}x${H}) -> $OUT"
