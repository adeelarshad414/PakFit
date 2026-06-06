# PakFit v0.40.0 Release Notes

## User-Facing Updates

- Adds an adult-use safety boundary for PakFit's Pakistani adult audience.
- Sets Android profile setup to an adult age floor of 18 for new profile entry.
- Adds Android and iOS warning behavior when a restored, imported, or programmatic profile is under 18.
- Shows iOS recommendation safety warnings in the Plan workflow.

## QA And Release Evidence

- Adds a release gate that validates Android age input, slider clamping, under-18 warning behavior, Swift recommendation parity, iOS safety warning display, tests, docs, and adult audience listing copy.
- Adds Android unit coverage plus Swift unit and smoke coverage for the under-18 adult-use warning.
- Includes adult-use safety status in CI, local release validation, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.40.0 build 40.

## Store Submission Boundary

This slice proves source-level adult-use posture. Final public release still requires store rating questionnaire review, legal/privacy review, and final age-suitability copy review.
