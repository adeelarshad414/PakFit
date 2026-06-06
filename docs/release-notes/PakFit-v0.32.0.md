# PakFit v0.32.0 Release Notes

## User-Facing Updates

- Adds generated English-only store screenshot previews for the key PakFit workflows: onboarding/plan, health markers, clinical screening, mental wellness, analysis dashboard, and food logging.
- Refreshes screenshot copy to match the current English-only product direction and remove stale non-English preview assets.
- Adds a contact sheet that makes the current app experience easier to review before store submission.

## QA And Release Evidence

- Adds a release gate that renders screenshot PNGs, validates expected dimensions, checks for nonblank output, and blocks non-current language text in the screenshot source.
- Includes screenshot evidence in release validation, CI, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.32.0 build 32.

## Store Submission Boundary

These are deterministic local screenshot previews for release review. Final Play Console and App Store Connect screenshots still need device-specific capture/review against the signed production binary and store artwork requirements.
