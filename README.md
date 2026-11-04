# Video Editing Starter Kit

A small, brand-free setup for editing videos with Claude Code.

## What you need (and what it costs)

- A paid **Claude** plan that includes Claude Code.
- A **Tella** account (required: recording and rough edit). Check that your plan includes exports and the Claude connector.
- An **Epidemic Sound** account (optional: music and sound effects).
- A Mac with Homebrew. Everything else in this kit is free.

Plans and prices change, so check each site before you sign up.

## Your "Video Editing" folder

1. On your computer, open **Documents** and create a folder named **Video Editing**.
2. Unzip this kit and put everything inside that folder.
3. Always open **this folder** in Claude Code. It's where Claude finds your skill, brand guide, scripts, and saved styles, and where it saves your finished videos.
4. Put your raw footage in the `raw-footage/` folder inside it, so Claude can find your clips by name.

The skill is called **video editing** (`.claude/skills/video-editing/SKILL.md`). Start a chat with `/video-editing` or just say "edit video X".

## Setup (once)

1. Install [Claude Code](https://claude.com/claude-code) and open the **Video Editing** folder in it.
2. Install the tools: `brew install ffmpeg node`
3. Connect these in Claude (Settings → Connectors):
   - **Tella** (required)
   - **Epidemic Sound** (optional)
4. Install the HyperFrames skills (motion graphics): run `npx hyperframes skills update` in this folder, then restart Claude Code so they load.
5. Check everything is installed: `scripts/check-setup.sh`
6. Try the practice run: `scripts/try-sample.sh`. It builds a fake test clip and runs it through the pipeline, so you know it works before using real footage.
7. Build your brand: open `BRAND.md`. Either ask **Claude Design** to create a brand guide, or tell Claude "fill in my BRAND.md" and it will interview you one question at a time.

## Recording setup

**Video**
- DSLR: 24mm lens at f/3.2, 4K, 30 fps.
- Or an iPhone: Settings → Camera → Record Video → 4K at 30 fps.
- Keep 30 fps everywhere. The scripts export at 30 fps, so mixing frame rates causes stutter.

**Audio**
- DJI Mic Mini with the charging case (clip it to your shirt, close to your mouth).
- Good audio matters more than video. Viewers forgive a soft picture, not bad sound.
- Do a quick test clip and listen with headphones before the real take.
- **No mic?** On an iPhone you can switch on spatial audio recording, or buy an adapter to plug a mic receiver straight into the phone. If you rely on the phone's own mic, record in a quiet room, close to the phone, and test first.

**Lighting**
- Three-point light setup:
  - **Key light**: your main light, in front of you at about 45° to one side, slightly above eye level.
  - **Fill light**: softer, on the opposite side, to lighten the shadows.
  - **Back light**: behind you, aimed at your head and shoulders, to separate you from the background.
- Set all three lights to 4000K (a neutral white), and set the camera's white balance to 4000K too. Matching them keeps skin tone natural and consistent from clip to clip.

**Framing and delivery**
- Put the lens at eye level and look at the lens, not the screen.
- Leave one second of silence before you start and after you finish. It makes cuts clean.
- Pause for a beat after a mistake and say the line again. Filler and silence are easy to cut in Tella.
- For Reels, keep your face and text in the middle of the frame (the top and bottom are covered by the app).

## Music rules

- Epidemic Sound tracks are licensed for your own channels. For YouTube, add your channel to the whitelist in your Epidemic account, or you may get Content ID claims.
- Instagram and TikTok have their own music rules. Music you add in the editor is covered by Epidemic. Don't mix in trending sounds from other apps unless you post it inside that app.
- Keep music quiet under your voice (the scripts do this for you).

## Privacy before you post

Blur anything that identifies a person or place unless you have permission: house numbers, street signs, license plates, documents, and other people's faces (especially kids). `scripts/blur.py` does this.

## Save your edits as skills (important)

Your markdown (`.md`) files are the most important part of working with Claude.

- When you like a version of your video, tell Claude: "create a skill / style .md file for this edit." It saves the settings (captions, music level, graphics, pacing) in the `styles/` folder so you don't have to explain them again.
- For each new video, open a **new chat** and point Claude to the skills or style files you want. Claude reads only those instead of a long chat history, which cuts token usage.

## Use

Tell Claude: "edit video X". It follows the workflow in `CLAUDE.md`: clean up in Tella, export, add music and an intro/outro, and deliver a finished file in `projects/<date>-<name>/exports/`.

Graphics are plain templates (dark background, indigo accent) until your brand guide is filled in. Ask Claude to change colors, fonts, or layout in `graphics/`.

## Back up your footage

Raw 4K footage is big (roughly 400 MB or more per minute). `raw-footage/` is the working copy Claude reads. Keep a second copy of the originals on an external drive or cloud storage, and delete from the phone or camera only after you've checked the backup. If your Mac is running low on space, move old raw clips to the external drive and keep only the current video's footage in the folder.
