# PakFit v0.39.0 Release Notes

## User-Facing Updates

- Strengthens PakFit's local-first privacy posture for sensitive health, food, calorie, lab-marker, and mental wellness data.
- Documents that the current build emits no diagnostic logs, crash reports, analytics events, or health-data telemetry.
- Keeps food-photo, calorie, BMI, cholesterol, uric acid, blood sugar, HbA1c, hemoglobin, and diabetes-related data out of developer-run diagnostics in this build.

## QA And Release Evidence

- Adds a diagnostic privacy gate that blocks runtime logging, stack-trace printing, unreviewed analytics SDKs, crash SDKs, and telemetry SDK patterns in Android and iOS runtime code.
- Validates privacy policy, store listing, Google Play Data safety, and App Store privacy drafts include the no-diagnostic-telemetry boundary.
- Includes diagnostic privacy status in CI, local release validation, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.39.0 build 39.

## Store Submission Boundary

This slice proves source-level and documentation-level diagnostic privacy posture. Final public release still requires signed-binary SDK declaration review, store-console SDK disclosure review, legal/privacy review, and confirmation that no external monitoring service is configured outside this repository.
