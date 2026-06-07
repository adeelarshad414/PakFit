# PakFit v0.41.0 Release Notes

## User-Facing Updates

- Adds an iOS Setup tab so users can edit profile and coaching inputs directly on iPhone.
- Adds iOS controls for theme, adult-safe age, height, weight, gender, goal, activity level, diet pattern, and training place.
- Adds iOS lifestyle-mode and medical-caution toggles so Ramadan, daawat weeks, office routines, eating out, budget planning, and health-safety flags can update recommendations.
- Keeps Setup changes connected to the shared recommendation, dashboard, health, safety-warning, and local snapshot model.

## QA And Release Evidence

- Adds an iOS setup parity gate that validates the Setup tab, adult age range, profile controls, lifestyle toggles, medical caution toggles, profile writeback, docs, and store listing copy.
- Includes iOS setup parity status in CI, local release validation, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.41.0 build 41.

## Store Submission Boundary

This slice proves source-level iOS Setup parity. Final production release still needs device QA for iPhone sizes, VoiceOver, large text, and signed production builds.
