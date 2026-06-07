# Agentic Development Pipeline

This repository now includes a PakFit-specific implementation of the specs-driven agentic pipeline from the attached master prompt.

## Current Fit To PakFit

PakFit is not a web app, Expo app, backend service, or database application in this release. The pipeline is adapted to native Android and iOS evidence:

- Start scripts run native validation instead of starting web services.
- Stop scripts clean tracked PIDs and optional ports without broad process killing by default.
- SPEC_MAP files describe native screens and demo scenarios instead of web routes and login roles.
- TEST_CREDENTIALS.csv contains deterministic demo scenario rows, with clear notes that no account login exists in the local-first build.
- Screenshot and video scripts use deterministic store-preview screens because there is no browser route tree.
- The Word setup guide is generated from the Markdown local setup guide.

## Included Artifacts

- `scripts/dev-start.sh`
- `scripts/dev-stop.sh`
- `scripts/dev-restart.sh`
- `scripts/dev-start.ps1`
- `scripts/dev-stop.ps1`
- `.vscode/tasks.json`
- `docs/COMMANDS_QUICKREF.md`
- `docs/SPEC_MAP.json`
- `docs/SPEC_MAP.md`
- `docs/TEST_CREDENTIALS.csv`
- `docs/LOCAL_SETUP_GUIDE.md`
- `docs/LOCAL_SETUP_GUIDE.docx`
- `docs/VIDEO_SCRIPT.md`
- `docs/VOICEOVER_RECORDING_GUIDE.md`
- `scripts/capture-screenshots.js`
- `scripts/record-demo.js`
- `scripts/assemble-video.sh`

## Release Boundary

This gate does not push to GitHub automatically, create a backend, create user accounts, install Playwright, or claim that native device videos were captured. Public release still requires Android/iOS device QA, signed Android upload, Apple signing, store submission, clinical copy review, and legal/privacy review.
