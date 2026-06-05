# Spec 026 - Store Privacy and Manifest Readiness

## Objective

Add platform privacy artifacts that align with PakFit's current local-first health app behavior and prepare the Android/iOS applications for store review conversations.

## Functional Requirements

- Add an iOS privacy manifest to the app target.
- Declare `UserDefaults` required-reason API usage for app-only local snapshot storage.
- Declare no tracking domains and no collected data types for the current no-backend/no-analytics build.
- Add draft privacy policy, Google Play Data safety mapping, and App Store privacy mapping.
- Add release validation checks for the privacy manifest.

## Non-Functional Requirements

- Store privacy artifacts must match actual current app behavior.
- Do not claim cloud sync, remote AI vision, backend accounts, or analytics.
- Keep store docs as drafts requiring legal/privacy review before public release.
- Use official platform guidance as the source of truth when store requirements change.

## Acceptance Evidence

- `PrivacyInfo.xcprivacy` exists and passes plist validation.
- Xcode project includes the privacy manifest in app resources.
- Local release validation passes.
- Store privacy docs exist under `docs/`.
