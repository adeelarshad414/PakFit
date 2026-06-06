# PakFit v0.35.0 Release Notes

## User-Facing Updates

- Adds stronger privacy-disclosure consistency for store readiness.
- Keeps PakFit's local-first health data, food photo, calorie search, and clinical-boundary disclosures aligned across Android, iOS, and store drafts.
- Documents that public privacy-policy hosting and legal review remain required before public submission.

## QA And Release Evidence

- Adds a release gate that cross-checks Android permissions, backup posture, iOS privacy manifest, iOS purpose strings, privacy policy draft, Google Play Data safety draft, App Store privacy draft, and store listing privacy summary.
- Blocks unsupported privacy claims such as enabled analytics, advertising SDKs, tracking, cloud sync, app-driven sharing, or remote photo upload.
- Includes store privacy disclosure status in release validation, CI, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.35.0 build 35.

## Store Submission Boundary

This slice proves local disclosure consistency. Public release still requires a hosted privacy-policy URL, Play Console/App Store Connect questionnaire review, and qualified legal/privacy approval.
