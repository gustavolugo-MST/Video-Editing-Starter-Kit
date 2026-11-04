---
name: video-editing
description: Edit a video start to finish with Tella, Epidemic Sound, HyperFrames and FFmpeg. Use when the user says "edit video", "video editing", or asks to clean up, add music, add an intro/outro, or export a video.
---

# Video Editing

Pipeline: Tella (record + rough edit) -> Epidemic Sound (music/SFX, optional) -> HyperFrames (intro/outro graphics) -> FFmpeg (assemble, duck music, normalize, deliver).

Work inside the "Video Editing" folder (Documents/Video Editing). Raw footage goes in `raw-footage/`. Read `BRAND.md` first; if it says "NOT FILLED IN YET", interview the user before any video work.

## Layout

```
scripts/     FFmpeg helpers (see below)
graphics/    HyperFrames project: index.html = intro, compositions/outro.html = outro
projects/<date>-<slug>/
  notes.md   Tella video ID, titles, chosen track
  tella/     exported Tella MP4
  music/ sfx/   downloaded audio
  graphics/  rendered intro/outro MP4s
  exports/   final deliverables
```

## Standard workflow for "edit video X"

1. `scripts/new-project.sh "<name>"` → project folder. Record the Tella video ID in `notes.md`.
2. **Tella clean-up** (ask before destructive edits like cutting clips): `get_transcript` → `remove_fillers` / `remove_silences` → `generate_auto_zooms` (screen recordings) → `apply_subtitle_preset` → `set_chapters`.
3. **Tella export**: `export_video` (fps "30"; `subtitles: true` only for burned-in captions) → poll `get_export_status` until `completed` → `scripts/fetch.sh <downloadUrl> projects/<p>/tella/main.mp4`.
4. **Music** (optional): `SearchRecordings` (vocals: false for talking videos) → share 3–5 options and let the user pick → `DownloadRecording` (`fileType: WAV`, `stemType: FULL`) → `scripts/fetch.sh <assetUrl> projects/<p>/music/<title>.wav`.
5. **Graphics**, rendered per format:
   - `scripts/render-graphics.sh FORMAT intro projects/<p>/graphics/intro-FORMAT.mp4 '{"title":"…","subtitle":"…"}'`
   - `scripts/render-graphics.sh FORMAT outro projects/<p>/graphics/outro-FORMAT.mp4 '{"headline":"…","cta":"…"}'`
   - Both accept `"accent":"#hex"`. Run `npm run check` in `graphics/` after editing a composition.
6. **Assemble**: `scripts/assemble.sh --format FORMAT --intro … --main … --outro … --music … --out projects/<p>/exports/FORMAT.mp4`
7. **Verify**: `scripts/probe.sh` the output (expect the format's size, 30 fps, ≈ -14 LUFS) and look at a few frames.
8. Optional quick clip: `scripts/vertical.sh final.mp4 short.mp4 <start> <duration>`.

## Formats

| FORMAT | Size | Use |
|---|---|---|
| `youtube` (default) | 1920x1080 16:9 | YouTube |
| `reels` | 1080x1920 9:16 | Reels, Shorts, TikTok |
| `feed` | 1080x1350 4:5 | Instagram feed |
| `square` | 1080x1080 1:1 | Square posts |

For non-16:9, the best way is to re-layout in Tella (`duplicate_video` → `update_video` with `dimensions` → `generate_auto_layouts` with a portrait/square style → export). Fallback: pass the 16:9 export to `assemble.sh --format …`; it centers the video over a blurred copy.

Keep text inside the centre on Reels: the top ~250px and bottom ~350px are covered by Instagram's UI.

## Scripts

| Script | Purpose |
|---|---|
| `new-project.sh NAME` | Create dated project folder |
| `fetch.sh URL OUT` | Download a Tella export / Epidemic signed URL |
| `formats.sh` | Shared format presets (sourced by other scripts) |
| `render-graphics.sh FORMAT intro\|outro OUT [VARS]` | Render HyperFrames intro/outro at a platform size |
| `conform.sh IN OUT [W H FPS]` | Normalize size/30fps/H.264/AAC; blur-fills mismatched shapes |
| `assemble.sh` | Join intro+main+outro, duck music under voice, loudnorm to -14 LUFS |
| `vertical.sh IN OUT [START DUR]` | 1080x1920 version over blurred background |
| `probe.sh FILE` | Specs + integrated loudness |
| `voice-roomtone.sh IN OUT` | Fix Tella Studio Sound audio: small sync shift + faint room tone in dead-silent pauses |
| `hdr2sdr.swift IN OUT` | iPhone HDR → SDR (run `swiftc -O scripts/hdr2sdr.swift -o /tmp/hdr2sdr` once). Do this before cutting iPhone clips |
| `blur.py` | Blur regions (addresses, faces, plates) |
| `check-setup.sh` | Check ffmpeg/node are installed |
| `try-sample.sh` | Practice run with a fake test clip |

Music level: `--music-db` (default -18). Loudness target: `--lufs`.

## Notes

- macOS ships bash 3.2: keep scripts compatible (no associative arrays, no `mapfile`).
- Tella's own `set_background_music` loops at fixed volume (no ducking); prefer FFmpeg for the final mix.
- Epidemic Sound: whitelist your YouTube channel in your Epidemic account to avoid Content ID claims.
