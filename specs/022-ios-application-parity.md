# Spec 022 - iOS Application Parity

## Objective

Add an iOS application path for PakFit so the product is no longer Android-only. The first iOS slice must preserve the same Pakistani health, nutrition, food tracking, light/dark theme, online calorie search, and food photo calorie-estimate workflows that are already present in the Android MVP.

## Functional Requirements

- Provide a SwiftUI iOS app entry point with Dashboard, Tracker, Health, and Plan sections.
- Show daily calorie intake, calorie burn, net calories, meal count, target calories, and progress.
- Support meal-level and hourly daily food tracking with newest-first history.
- Include the default Pakistani food catalog for roti, rice, daal, protein, sabzi, dairy, desi dishes, desserts, drinks, and snacks.
- Support manual food item entry with custom category, serving, and calories.
- Provide online calorie search using Pakistani food context.
- Provide a photo-estimate workflow that accepts a food hint and portion size, returns calories, and labels confidence.
- Calculate BMI with South Asian screening cutoffs.
- Flag lipid profile, uric acid, fasting blood sugar, HbA1c, hemoglobin, diabetes status, and blood pressure concerns.
- Include a light, dark, and system theme selector.
- Keep all user-facing copy English-only.

## Non-Functional Requirements

- Keep clinical content framed as screening information, not diagnosis or treatment.
- Keep food photo calories explainable and confidence-labeled until a real model/backend is integrated.
- Use a shared Swift core with unit tests so iOS behavior can be validated without a simulator.
- Keep the iOS app offline-first except for explicit online search links.
- Preserve privacy by avoiding account, analytics, cloud sync, or remote image upload in this slice.
- Keep UI dense, readable, and production-oriented for repeated daily use.

## Test Strategy

- Unit-test calorie target generation for Pakistani profiles.
- Unit-test daily meal/hour calorie tracking and manual food entries.
- Unit-test BMI and marker flags for cholesterol, uric acid, sugar, HbA1c, hemoglobin, diabetes, and blood pressure.
- Unit-test online search URL generation.
- Unit-test food photo estimates for catalog matches and unknown foods.
- Provide a no-XCTest smoke runner for local Command Line Tools environments that cannot load `XCTest`.

## Acceptance Evidence

- `ios/PakFitIOS` contains a SwiftUI app and testable Swift core.
- `swift test` passes for `PakFitCoreTests` when the Swift toolchain is available.
- `swift run PakFitCoreSmokeTests` passes in a Command Line Tools environment.
- README documents Android and iOS run/test paths.
- Android APK remains available as the current Android artifact.
