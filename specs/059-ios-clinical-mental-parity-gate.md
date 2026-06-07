# Spec 059: iOS Clinical And Mental Wellness Parity Gate

## Goal

Bring iOS closer to Android Health workflow parity by exposing clinical risk inputs, clinical insights, mental wellness screeners, crisis flags, and Pakistan crisis resources in the iOS Health workflow.

## Functional Requirements

- Add Swift clinical risk report models and a `ClinicalIntelligenceEngine`.
- Add Swift mental wellness report models and a `MentalWellnessEngine`.
- Add Swift smoke-test coverage for clinical risk sorting, diabetes/cardiovascular insights, PHQ-9/GAD-7 severity, crisis escalation, and Pakistan emergency support.
- Add iOS Health controls for clinical risk factors.
- Add iOS Health clinical insights for diabetes risk, BP risk, heart risk, vitamin D risk, and anemia risk.
- Add iOS Health controls for PHQ-9, GAD-7, self-harm thoughts, panic or severe distress, and inability to stay safe.
- Add iOS crisis escalation copy and Pakistan support resources when crisis flags are selected.
- Keep clinical and mental wellness edits connected to shared iOS snapshot state.
- Document the iOS clinical and mental wellness parity posture and release boundary.

## Non-Functional Requirements

- The gate must run locally and in CI without simulators, signing, Play Console, or App Store Connect.
- The implementation must not weaken adult-use safety, privacy, diagnostic privacy, accessibility, signing, store, dependency, security, setup parity, health marker parity, or lifestyle coach parity gates.
- Clinical and mental wellness copy must remain non-diagnostic and English-only for the current release.

## Acceptance Evidence

- `bash scripts/validate-ios-clinical-mental-parity.sh` passes.
- `bash scripts/validate-release.sh` runs the iOS clinical and mental wellness parity gate.
- Swift smoke/app compile passes.
- Generated release evidence includes iOS clinical and mental wellness parity status and documentation checksum.
- Android and iOS versions remain aligned at the current release version.
