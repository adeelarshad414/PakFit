# PakFit Accessibility And Readability Readiness

PakFit is a health, fitness, workout, and nutrition app for Pakistani users, including people reviewing dense food logs, lab markers, glucose, cholesterol, uric acid, HbA1c, hemoglobin, workouts, and mental wellness information on small screens. The app must stay readable, operable, and understandable for users with limited vision, temporary injury, older devices, and screen readers.

## Current Local Gate

- Android Compose headings are marked with semantic heading roles for major app and card sections.
- Android custom metric tiles, todos, chart bars, and progress bars expose combined text alternatives instead of relying only on visual layout.
- Android food photo previews require a non-empty content description.
- iOS custom stat tiles, progress summaries, trend bars, food-photo estimates, health flags, and todo rows expose accessibility labels.
- iOS decorative symbols are hidden from VoiceOver when the adjacent text already carries the meaning.
- iOS prominent health values use Dynamic Type-friendly styles instead of fixed-size SwiftUI fonts.

## Product Rules

- Do not communicate health risk, progress, calories, or todo status by color alone.
- Keep custom charts backed by readable text values and screen reader labels.
- Keep food-photo calorie estimates explicitly approximate, user-confirmed, and non-diagnostic.
- Prefer platform typography styles that respect user text-size settings.
- Keep copy in English for this release while staying culturally specific to Pakistani meals and routines.

## Release Boundary

The static gate catches source-level regressions only. Before public release, PakFit still needs device-based TalkBack and VoiceOver review, large-text visual QA, keyboard/switch-control checks where applicable, and final screenshots from signed production builds.
