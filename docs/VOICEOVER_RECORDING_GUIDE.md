# PakFit Voiceover Recording Guide

## Recording Setup

- Record in a quiet room with soft surfaces.
- Use a USB microphone or a close phone microphone.
- Record WAV or high-quality AAC before exporting final audio.
- Keep the final export at 48 kHz AAC when assembling the production video.

## Tone

- Calm, confident, and professional.
- Avoid hype or medical certainty.
- Treat health, diabetes, pregnancy, blood pressure, kidney disease, mental wellness, and PCOS as clinician-review areas.
- Emphasize that PakFit supports education, planning, screening, and habit coaching only.

## Pacing

- Leave one to two seconds of silence before each scene.
- Read about 130 to 145 words per minute.
- Pause slightly after clinical-safety boundaries so the message lands.
- If the UI scrolls, wait until the scroll finishes before starting the next sentence.

## Sync Workflow

1. Generate screenshots or silent clips:
   ```bash
   node scripts/record-demo.js
   bash scripts/assemble-video.sh
   ```
2. Import `docs/PRODUCT_DEMO.mp4` or native device recordings into DaVinci Resolve, iMovie, or Audacity plus a video editor.
3. Record the script from `docs/VIDEO_SCRIPT.md`.
4. Align each scene heading with the matching visual section.
5. Add light background music only if it does not compete with clinical-safety wording.
6. Export at 1080p, H.264 video, AAC audio, and 48 kHz audio sample rate.

## Review Checklist

- No promise of cure, diagnosis, prescribed treatment, or guaranteed weight loss.
- Medication and lab-result wording stays clinician-reviewed.
- Food-photo estimates are described as approximate.
- Privacy wording matches the local-first build.
- Android and iOS visuals match the current release version.
