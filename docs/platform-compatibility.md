# Platform Compatibility Readiness

Last checked: 2026-06-07

This document records the current platform SDK posture used by PakFit release validation.

## Android

- `compileSdk`: 35
- `targetSdk`: 35
- `minSdk`: 26
- Android Gradle Plugin: 8.6.1
- Local validation requires the Android API 35 platform to be installed.
- GitHub Actions installs `platforms;android-35` and `build-tools;35.0.0` before running release gates.

The Google Play target API requirement currently says new apps and app updates submitted to Google Play must target Android 15, API level 35, or higher starting August 31, 2025:

https://developer.android.com/google/play/requirements/target-sdk

The Android build toolchain gate requires an Android Gradle Plugin line that supports API 35 and blocks `android.suppressUnsupportedCompileSdk`, so build warnings are fixed through toolchain upgrades rather than hidden.

Android Gradle Plugin 8.6 release notes state that AGP 8.6 supports API level 35:

https://developer.android.com/build/releases/agp-8-6-0-release-notes

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
