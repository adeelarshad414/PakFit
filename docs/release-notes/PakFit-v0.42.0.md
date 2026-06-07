# PakFit v0.42.0 Release Notes

## User-Facing Updates

- Adds editable iOS health marker inputs in the Health workflow.
- Adds iOS controls for diabetes status, lipid profile, uric acid, fasting blood sugar, blood pressure, HbA1c, hemoglobin, and severe symptom escalation.
- Keeps marker edits connected to the shared iOS lab profile so health flags, emergency warnings, local snapshots, and export previews use current values.

## QA And Release Evidence

- Adds an iOS health marker parity gate that validates marker controls, lab-profile writeback, docs, and store listing copy.
- Includes iOS health marker parity status in CI, local release validation, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.42.0 build 42.

## Store Submission Boundary

This slice proves source-level iOS Health marker parity. Final production release still needs iPhone device QA, VoiceOver, large-text review, and clinical copy review.
