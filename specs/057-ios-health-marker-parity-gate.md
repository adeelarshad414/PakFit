# Spec 057: iOS Health Marker Parity Gate

## Goal

Bring iOS closer to Android health workflow parity by letting users edit health marker values that drive BMI reports, lipid profile review, uric acid review, blood sugar review, HbA1c review, hemoglobin review, diabetes status review, blood pressure review, and emergency symptom escalation.

## Functional Requirements

- Add an iOS Health marker input panel.
- Let users edit diabetes status.
- Let users edit lipid profile values: total cholesterol, LDL, HDL, and triglycerides.
- Let users edit uric acid, fasting blood sugar, HbA1c, and hemoglobin.
- Let users edit systolic and diastolic blood pressure.
- Let users toggle chest pain or severe symptoms for emergency escalation behavior.
- Keep marker edits connected to shared `PakFitViewModel.labProfile` so reports, snapshots, and privacy boundaries use one current state.
- Document the iOS health marker parity posture and release boundary.

## Non-Functional Requirements

- The gate must run locally and in CI without simulators, signing, Play Console, or App Store Connect.
- The implementation must not weaken adult-use safety, privacy, diagnostic privacy, accessibility, signing, store, dependency, or security gates.
- Health copy must remain non-diagnostic and English-only for the current release.

## Acceptance Evidence

- `bash scripts/validate-ios-health-marker-parity.sh` passes.
- `bash scripts/validate-release.sh` runs the iOS health marker parity gate.
- Swift smoke/app compile passes.
- Generated release evidence includes iOS health marker parity status and documentation checksum.
- Android and iOS versions remain aligned at the current release version.
