# App Store Privacy Draft

This draft maps current PakFit behavior to App Store privacy and privacy manifest readiness. It must be reviewed before App Store submission.

## Current App Behavior

- No account backend.
- No cloud sync.
- No analytics SDK.
- No advertising or tracking.
- Sensitive health and fitness information stays local to the user's device unless the user chooses an export preview.
- The sensitive iOS snapshot payload is stored in Keychain. UserDefaults is used only for non-sensitive local state and migration markers.
- iOS online calorie search uses an HTTPS user-controlled web search handoff, and the current build does not define ATS cleartext opt-outs.
- Food photo image bytes are not saved in snapshots and are not uploaded by this build.

## Privacy Manifest

PakFit includes `PrivacyInfo.xcprivacy` in the iOS app target resources.

Declared current behavior:

- `NSPrivacyTracking`: false.
- `NSPrivacyTrackingDomains`: empty.
- `NSPrivacyCollectedDataTypes`: empty because this build does not transmit user data to the developer or third parties.
- `NSPrivacyAccessedAPITypes`: declares `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1` because the app reads and writes app-only local state through `UserDefaults`.

## App Privacy Labels Draft

For the current no-backend build:

- Data used to track users: No.
- Data linked to user and collected by developer: No remote collection in this build.
- Data not linked to user and collected by developer: No remote collection in this build.

## Review Notes

If future work adds accounts, backend sync, analytics, crash reporting SDKs, ads, push notifications, HealthKit, or remote image processing, this document, the privacy manifest, and App Store privacy labels must be updated before release.
