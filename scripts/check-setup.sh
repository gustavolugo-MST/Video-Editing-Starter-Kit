#!/usr/bin/env bash
# Check that the tools the starter kit needs are installed.
# Usage: scripts/check-setup.sh
ok=1
check() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "OK       $1"
  else
    echo "MISSING  $1  ->  $2"; ok=0
  fi
}
check ffmpeg  "brew install ffmpeg"
check ffprobe "brew install ffmpeg"
check node    "brew install node"
check npx     "brew install node"
check swiftc  "xcode-select --install (only needed for hdr2sdr.swift)"
echo
echo "Also connect Tella (required) and Epidemic Sound (optional) in Claude: Settings -> Connectors."
[ "$ok" = 1 ] && echo "All tools found." || { echo "Fix the MISSING items above, then run this again."; exit 1; }
