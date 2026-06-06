# Spec 053: Accessibility And Readability Gate

## Goal

Add a release gate that keeps PakFit usable for screen reader and large-text users while preserving the professional health-coach workflow for Pakistani food, workout, calorie, lab-marker, and mental wellness tracking.

## Functional Requirements

- Mark major Android Compose sections as semantic headings.
- Expose Android custom progress bars, chart bars, metric tiles, and todo rows as meaningful text to assistive technology.
- Require Android food-photo previews to include a non-empty content description.
- Expose iOS custom stat tiles, progress summaries, trend bars, food-photo estimates, health flags, and todo rows through accessibility labels.
- Use Dynamic Type-friendly SwiftUI text styles for prominent iOS health values instead of fixed-size fonts.
- Document the accessibility posture and external device-review boundary.

## Non-Functional Requirements

- The gate must be deterministic and runnable in local release validation and CI without device emulators.
- The gate must avoid network access and avoid adding third-party dependencies.
- The gate must not weaken existing privacy, signing, store, dependency, security, or clinical-safety gates.
- The implementation must remain English-only for the current release.

## Acceptance Tests

- `bash scripts/validate-accessibility-readability.sh` passes.
- `bash scripts/validate-release.sh` runs the accessibility/readability gate.
- Generated release evidence includes accessibility/readability status.
- Android and iOS versions remain aligned at the current release version.
