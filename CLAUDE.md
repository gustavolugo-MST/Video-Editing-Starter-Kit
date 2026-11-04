# Video Editing

This folder is "Video Editing" (Documents/Video Editing). It holds everything for editing videos with Claude.

**Brand (loaded automatically):** @BRAND.md

If `BRAND.md` still says "NOT FILLED IN YET", interview the user with its questions (one at a time) before any video work, or send them to Claude Design to build a brand guide. Until then, graphics use a neutral dark theme with an indigo accent.

**To edit a video, use the `video-editing` skill.** It holds the full workflow, formats and scripts.

**Folders:** `raw-footage/` (original camera/phone clips), `projects/` (one folder per video), `styles/` (saved edit styles), `scripts/` (FFmpeg helpers), `graphics/` (HyperFrames intro/outro).

**Saved styles:** when the user likes an edit, create a style `.md` file (or skill) that records its settings (captions, music level, graphics, pacing) in `styles/`, and tell them to point new chats at it.
