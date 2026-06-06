# PakFit v0.38.0 Release Notes

## User-Facing Updates

- Improves accessibility for Android dashboard metrics, charts, progress bars, todo rows, and captured food-photo previews.
- Improves iOS VoiceOver support for stat tiles, progress summaries, trend bars, food-photo calorie estimates, todo rows, and health-marker flags.
- Replaces fixed-size iOS headline values with Dynamic Type-friendly styles so BMI and calorie target text better respect user text-size settings.

## QA And Release Evidence

- Adds a release gate that validates Android Compose semantic headings, progress range semantics, image descriptions, and combined labels for custom visual controls.
- Adds iOS source checks for Dynamic Type-friendly fonts, accessibility labels, decorative icon hiding, and custom chart accessibility.
- Includes accessibility/readability status in CI, release validation, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.38.0 build 38.

## Store Submission Boundary

This slice proves source-level accessibility posture. Final production submission still requires TalkBack, VoiceOver, large-text, keyboard, switch-control, and signed-device QA.
