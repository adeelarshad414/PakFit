# Spec 025 - Release Automation and CI Gates

## Objective

Move PakFit from manual-only validation toward repeatable production release evidence for Android and iOS. The repository must include local validation scripts and CI gates that can prove tests, APK build, Swift/iOS compile, source-language policy, and basic secret hygiene.

## Functional Requirements

- Provide a local release validation script that runs Android unit tests, builds the debug APK, runs the iOS Swift smoke suite, compiles the SwiftUI app target, and checks English-only app source.
- Provide an APK export script that copies the built debug APK to a versioned destination using build metadata.
- Add GitHub Actions CI for Android unit tests and debug APK artifact upload.
- Add GitHub Actions CI for iOS Swift smoke tests and SwiftUI app target compile.
- Add source quality gates for English-only app source and obvious hardcoded secret patterns.

## Non-Functional Requirements

- CI must not require backend services, production signing secrets, analytics credentials, or cloud health data.
- Debug APK artifact upload must use generated build output only.
- Release signing stays out of scope until secure secret storage is configured.
- iOS App Store archive/signing remains blocked until full Xcode and signing assets are available.

## Acceptance Evidence

- `scripts/validate-release.sh` passes locally.
- `scripts/export-android-debug-apk.sh` can export a versioned debug APK after validation.
- `.github/workflows/pakfit-ci.yml` defines Android, iOS Swift, and source-gate jobs.
- README and release spec document the repeatable gates.
