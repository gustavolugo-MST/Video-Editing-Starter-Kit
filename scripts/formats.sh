# Shared platform presets. Source this file, then call: format_dims FORMAT
# Sets W, H and RES (HyperFrames resolution name).
format_dims() {
  case "$1" in
    youtube|landscape|16x9) W=1920; H=1080; RES=landscape ;;
    reels|shorts|tiktok|story|vertical|9x16) W=1080; H=1920; RES=portrait ;;
    feed|portrait|4x5) W=1080; H=1350; RES=portrait ;;
    square|1x1) W=1080; H=1080; RES=square ;;
    *) echo "unknown format '$1' (use youtube, reels, feed or square)" >&2; return 1 ;;
  esac
}
