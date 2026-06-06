# Platform Compatibility Readiness

Last checked: 2026-06-07

This document records the current platform SDK posture used by PakFit release validation.

## Android

- `compileSdk`: 35
- `targetSdk`: 35
- `minSdk`: 26
- Local validation requires the Android API 35 platform to be installed.
- GitHub Actions installs `platforms;android-35` and `build-tools;35.0.0` before running release gates.

The Google Play target API requirement currently says new apps and app updates submitted to Google Play must target Android 15, API level 35, or higher starting August 31, 2025:

https://developer.android.com/google/play/requirements/target-sdk

Known local tooling follow-up: the current Android Gradle Plugin version builds successfully with API 35 but emits a tested-through-API-34 warning. The next toolchain-hardening slice should upgrade AGP and refresh dependency verification metadata instead of suppressing the warning.

## iOS

- `IPHONEOS_DEPLOYMENT_TARGET`: 16.0
- `SWIFT_VERSION`: 5.0
- The local Codex environment validates SwiftPM smoke tests and SwiftUI target compile.
- App Store upload/archive remains an external boundary until full Xcode.app, signing assets, and App Store Connect access are available.

Apple's current upcoming requirements state that apps uploaded to App Store Connect must be built with Xcode 26 or later using an SDK for iOS/iPadOS 26 or later:

https://developer.apple.com/news/upcoming-requirements/

## Validation

Run `bash scripts/validate-platform-compatibility.sh` directly or through `bash scripts/validate-release.sh`.

This gate proves source/build metadata and local Android SDK readiness. It does not prove Play Console acceptance, App Store archive signing, App Store Connect upload, or legal/store review completion.
