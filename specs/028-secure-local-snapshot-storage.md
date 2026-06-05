# Spec 028 - Secure Local Snapshot Storage

## Objective

Protect PakFit's sensitive local health snapshot at rest on both Android and iOS while keeping export preview user-controlled and explicit.

## Functional Requirements

- Android saves local snapshots as encrypted payloads in SharedPreferences.
- Android encryption uses an Android Keystore-backed AES-GCM key.
- Android can restore legacy plaintext snapshots and rewrites them encrypted after successful restore.
- iOS saves the sensitive snapshot payload in Keychain.
- iOS uses UserDefaults only for non-sensitive local state and legacy plaintext migration markers.
- iOS can restore a legacy UserDefaults payload, migrate it into Keychain, and remove the plaintext payload.
- Export preview remains user-controlled plaintext and does not imply secure backup.

## Non-Functional Requirements

- Do not add cloud sync, accounts, analytics, or remote backup.
- Do not store food photo image bytes.
- Keep consent gating before save/export.
- Keep platform privacy docs aligned with the actual storage behavior.

## Acceptance Evidence

- Android `testDebugUnitTest assembleDebug` passes.
- iOS `swift run PakFitCoreSmokeTests` passes.
- iOS `swift build --target PakFitApp` passes.
- `scripts/validate-release.sh` passes and generates release evidence.
