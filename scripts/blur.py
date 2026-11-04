#!/usr/bin/env python3
"""Privacy blur for stills (rule: always blur addresses and house numbers, for-sale signs, plates,
and anything that identifies people; blur children's faces).
Usage: blur.py IN OUT x,y,w,h [x,y,w,h ...]   (pixel boxes in IN's own size). Pixelates + blurs each box (not reversible).
Works on video too (.mp4/.mov out): boxes are static, so leave a margin and check first/middle/last frames. Check the result by eye."""
import subprocess, sys
src, out, boxes = sys.argv[1], sys.argv[2], [list(map(int, b.split(","))) for b in sys.argv[3:]]
fc, cur = [], "[0:v]"
for i, (x, y, w, h) in enumerate(boxes):
    fc.append("%scrop=%d:%d:%d:%d,scale=max(4\\,%d/14):-2:flags=neighbor,scale=%d:%d:flags=neighbor,boxblur=%d:1[b%d]" % ("[0:v]", w, h, x, y, w, w, h, max(1, min(w, h) // 10), i))
    fc[-1] = fc[-1]
    nxt = "[o%d]" % i
    fc.append("%s[b%d]overlay=%d:%d%s" % (cur, i, x, y, nxt)); cur = nxt
vid = out.lower().endswith((".mp4", ".mov"))
enc = ["-an", "-c:v", "libx264", "-crf", "16", "-g", "30", "-keyint_min", "30", "-pix_fmt", "yuv420p", "-movflags", "+faststart"] if vid else ["-frames:v", "1", "-q:v", "2"]
subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-y", "-i", src, "-filter_complex", ";".join(fc), "-map", cur] + enc + [out], check=True)
print("blurred", len(boxes), "regions ->", out)
