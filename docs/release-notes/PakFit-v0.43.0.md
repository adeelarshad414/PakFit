# PakFit v0.43.0 Release Notes

## User-Facing Updates

- Adds editable iOS Dashboard controls for calories burned, water, steps, sleep, workout minutes, and stress.
- Adds a dynamic iOS Daily Coach Review with score, strengths, and prioritized next actions.
- Uses food logs, daily burn, lifestyle inputs, and health flags to guide nutrition, meal timing, hydration, activity, recovery, and health-safety coaching.

## QA And Release Evidence

- Adds an iOS lifestyle coach parity gate that validates Swift coach models, coach engine logic, smoke tests, Dashboard controls, docs, and store listing copy.
- Includes iOS lifestyle coach parity status in CI, local release validation, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.43.0 build 43.

## Store Submission Boundary

This slice proves source-level iOS daily lifestyle and coach review parity. Final production release still needs iPhone device QA, VoiceOver, large-text review, and health/coach copy review.
