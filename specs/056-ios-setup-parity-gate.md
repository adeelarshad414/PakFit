# Spec 056: iOS Setup Parity Gate

## Goal

Bring iOS closer to Android workflow parity by adding an editable Setup tab for profile, goal, routine, diet, lifestyle mode, and medical caution inputs used by PakFit's recommendation, dashboard, health, and local snapshot features.

## Functional Requirements

- Add an iOS Setup tab to the main `TabView`.
- Let users select theme mode from Setup.
- Let users edit adult-safe profile values: age 18-75, height, weight, and gender.
- Let users edit goal, activity level, diet pattern, and training place.
- Let users toggle lifestyle modes and medical cautions.
- Keep Setup edits connected to the shared `PakFitViewModel.profile` so all computed plan, dashboard, health, safety warning, and snapshot behavior refreshes from one profile.
- Document the iOS setup parity posture and release boundary.

## Non-Functional Requirements

- The gate must be deterministic and runnable in local validation and CI without simulators, signing, Play Console, or App Store Connect.
- The implementation must not weaken adult-use safety, privacy, diagnostic privacy, accessibility, signing, store, dependency, or security gates.
- Setup copy must remain English-only for the current release while preserving Pakistani context.

## Acceptance Evidence

- `bash scripts/validate-ios-setup-parity.sh` passes.
- `bash scripts/validate-release.sh` runs the iOS setup parity gate.
- Swift smoke/app compile passes.
- Generated release evidence includes iOS setup parity status and documentation checksum.
- Android and iOS versions remain aligned at the current release version.
