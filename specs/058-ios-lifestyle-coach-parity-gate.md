# Spec 058: iOS Lifestyle Coach Parity Gate

## Goal

Bring iOS closer to Android Dashboard parity by letting users edit daily burn and lifestyle inputs and by replacing static coach todo text with a dynamic coach review.

## Functional Requirements

- Add iOS Dashboard controls for calories burned today, water, steps, sleep, workout minutes, and stress.
- Add Swift coach review models for coaching area, priority, action, and review summary.
- Add a Swift `CoachReviewEngine` that uses food logs, nutrition targets, health flags, and daily lifestyle records.
- Show a Daily Coach Review on iOS with score, strengths, and prioritized next actions.
- Keep daily input edits connected to `PakFitViewModel.lifestyleRecord`, daily calorie burn, secure snapshots, and visible coach review output.
- Document the iOS lifestyle coach parity posture and release boundary.

## Non-Functional Requirements

- The gate must run locally and in CI without simulators, signing, Play Console, or App Store Connect.
- The implementation must not weaken adult-use safety, privacy, diagnostic privacy, accessibility, signing, store, dependency, security, setup parity, or health marker parity gates.
- Coach copy must remain non-diagnostic and English-only for the current release.

## Acceptance Evidence

- `bash scripts/validate-ios-lifestyle-coach-parity.sh` passes.
- `bash scripts/validate-release.sh` runs the iOS lifestyle coach parity gate.
- Swift smoke/app compile passes.
- Generated release evidence includes iOS lifestyle coach parity status and documentation checksum.
- Android and iOS versions remain aligned at the current release version.
