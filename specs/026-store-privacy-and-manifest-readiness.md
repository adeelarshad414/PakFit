# Spec 026 - Store Privacy and Manifest Readiness

## Objective

Add platform privacy artifacts that align with PakFit's current local-first health app behavior and prepare the Android/iOS applications for store review conversations.

## Functional Requirements

- Add an iOS privacy manifest to the app target.
- Declare `UserDefaults` required-reason API usage for app-only local state and migration markers.
- Declare no tracking domains and no collected data types for the current no-backend/no-analytics build.
- Keep iOS camera/photo library purpose strings scoped to user-selected food photos for visible calorie estimation.
- Add draft privacy policy, Google Play Data safety mapping, and App Store privacy mapping.
- Add release validation checks for the privacy manifest.
- Add release validation checks for iOS permission purpose-string posture.

## Non-Functional Requirements

- Store privacy artifacts must match actual current app behavior.
- Do not claim cloud sync, remote AI vision, backend accounts, or analytics.
- Keep store docs as drafts requiring legal/privacy review before public release.
- Use official platform guidance as the source of truth when store requirements change.

## Acceptance Evidence

- `PrivacyInfo.xcprivacy` exists and passes plist validation.
- Xcode project includes the privacy manifest in app resources.
- iOS camera/photo purpose strings exist in Debug and Release build settings and pass the permission privacy gate.
- Local release validation passes.
- Store privacy docs exist under `docs/`.
