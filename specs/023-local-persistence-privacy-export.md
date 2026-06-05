# Spec 023 - Local Persistence and Privacy Export

## Objective

Close the largest production-readiness gap left in the MVP audit: app state is in memory only. PakFit must give users a local snapshot path for profile, health markers, food records, lifestyle inputs, mental wellness screening inputs, clinical risk factors, and custom foods without pretending that a backend or cloud sync exists.

## Functional Requirements

- Save and restore a versioned local user snapshot on device.
- Include profile, goal, activity, diet, training place, lifestyle modes, equipment, and medical cautions.
- Include lipid profile, uric acid, fasting blood sugar, HbA1c, hemoglobin, diabetes status, blood pressure, and emergency symptom flags.
- Include the current daily food record, meal times, servings, calories burned, and manual food items.
- Include daily lifestyle inputs for water, steps, sleep, workout minutes, and stress.
- Include PHQ-9/GAD-7 score inputs, mental support flags, and clinical risk factors.
- Provide an export payload for user-controlled backup or support review.
- Provide a clear/delete local snapshot action.
- Do not store food photo image bytes in the snapshot.

## Non-Functional Requirements

- Use a schema version so future migrations can reject unsupported payloads safely.
- Keep the snapshot offline-first and local; no sync, analytics, account, or backend behavior should be implied.
- Keep medical and mental wellness content framed as sensitive health data.
- Keep all current app copy English-only.
- Add unit tests for round-trip restore, summary counts, and migration rejection.

## Acceptance Evidence

- Android includes a pure Kotlin snapshot codec and SharedPreferences-backed local store.
- iOS includes a Codable snapshot path and local UserDefaults actions.
- Domain tests prove snapshot round-tripping and unsupported schema rejection.
- Android unit tests and debug APK build pass.
- iOS SwiftPM app compile and core smoke tests pass.
