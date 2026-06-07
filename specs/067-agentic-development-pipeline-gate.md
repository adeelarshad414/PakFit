# Spec 067 - Agentic Development Pipeline Gate

## Objective

Add the missing developer-experience artifacts from the attached specs-driven agentic pipeline prompt in a PakFit-native way. The gate must help a developer start, stop, validate, inspect, demo, and document the Android/iOS application without pretending PakFit has a backend, database, web route tree, Expo app, or login system.

## Functional Requirements

- Add shell start, stop, and restart scripts for native validation.
- Add PowerShell start and stop scripts for Windows users.
- Add VS Code tasks for start, stop, restart, release validation, screenshot capture, and demo recording.
- Add `docs/COMMANDS_QUICKREF.md` with Android, iOS, release, stop/kill, and log commands.
- Add machine-readable and human-readable SPEC_MAP files.
- Add deterministic demo scenario credentials with explicit local-only/no-login notes.
- Add local setup guide Markdown and DOCX.
- Add video script and voiceover recording guide.
- Add screenshot and demo recording orchestration scripts adapted to deterministic native app preview screens.
- Add a release validation gate and CI wiring for these artifacts.
- Add release evidence report coverage for the new gate.

## Non-Functional Requirements

- Do not add a backend, database, auth service, Expo server, or web frontend.
- Do not add broad kill behavior by default.
- Keep all generated docs English-only.
- Keep medical, clinical, mental health, and food-photo claims within existing PakFit boundaries.
- Keep GitHub push as an explicit user-driven action, not an automatic gate side effect.

## Acceptance Evidence

- `scripts/validate-agentic-pipeline.sh` passes.
- `scripts/validate-release.sh` includes the agentic pipeline gate.
- `.github/workflows/pakfit-ci.yml` includes the agentic pipeline gate.
- `scripts/generate-release-report.sh` includes agentic pipeline documentation checksum and gate status.
- `docs/SPEC_MAP.json` parses as JSON and states no backend/database runtime exists.
- `docs/LOCAL_SETUP_GUIDE.docx` exists and is generated from the setup guide.

## Acceptance Criteria

### Scenario: Developer can find start and stop commands

Given a developer opens the repository
When they read `docs/COMMANDS_QUICKREF.md`
Then they can find start, stop, restart, Android, iOS, release, screenshot, demo, stop/kill, and log commands.

### Scenario: Spec map reflects native architecture

Given PakFit has no backend or web route tree
When `docs/SPEC_MAP.json` is generated
Then it uses native route IDs
And it states backend, database, services, and ports are absent in this build.

### Scenario: Demo personas do not imply accounts

Given PakFit has no auth backend
When `docs/TEST_CREDENTIALS.csv` is generated
Then each row is a deterministic demo scenario
And the password field clearly says local-only/no account login.
