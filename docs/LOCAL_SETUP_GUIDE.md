# PakFit Local Setup Guide

## 1. Stack Summary

PakFit is a native Android and iOS application:

- Android: Kotlin, Jetpack Compose, Gradle Wrapper, Android SDK 35.
- iOS: SwiftUI, Swift Package Manager, Xcode project, iOS 16 deployment target.
- Backend: none in this build.
- Database: none in this build.
- Runtime services: none in this build.
- Auth accounts: none in this build.

## 2. Prerequisites

Install or verify:

- JDK 17.
- Android SDK command-line tools with platform `android-35`.
- Swift 5.9 or newer for Swift package validation.
- Full Xcode.app for simulator/device signing and IPA/TestFlight work.
- `ripgrep` for source gates.
- Python 3 with Pillow for screenshot generation.
- Optional: `ffmpeg` for demo-video assembly.

On this Codex machine, the common paths are:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export ANDROID_SDK_ROOT=$ANDROID_HOME
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
```

## 3. Start Local Validation

```bash
bash scripts/dev-start.sh
```

This runs Android unit tests, builds the debug APK, runs Swift smoke tests when Swift is available, and compiles the SwiftUI target.

PakFit does not start long-running services, so `logs/dev-pids.txt` is intentionally empty unless a future workflow adds background processes.

## 4. Android Development

Run tests:

```bash
./gradlew --dependency-verification strict testDebugUnitTest
```

Build debug APK:

```bash
./gradlew --dependency-verification strict assembleDebug
```

Install to a connected Android device:

```bash
adb devices
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell monkey -p com.pakfit.app 1
```

## 5. iOS Development

Run Swift smoke tests:

```bash
cd ios/PakFitIOS
swift run PakFitCoreSmokeTests
```

Compile the SwiftUI app target:

```bash
cd ios/PakFitIOS
swift build --target PakFitApp
```

Open in Xcode for simulator or device testing:

```bash
open ios/PakFitIOS/PakFitIOS.xcodeproj
```

The local handoff archive is source/project review evidence, not a signed IPA:

```bash
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-ios-app-handoff.sh
```

## 6. Release Validation

Run the full local release gate:

```bash
bash scripts/validate-release.sh
```

Export release artifacts:

```bash
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-android-debug-apk.sh
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-android-release-artifacts.sh
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-ios-app-handoff.sh
```

Generate reports:

```bash
REPORT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit/reports bash scripts/generate-dependency-inventory.sh
REPORT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit/reports bash scripts/generate-release-report.sh
```

## 7. Screenshots And Demo Video

Capture deterministic store-preview screenshots:

```bash
node scripts/capture-screenshots.js
```

Generate silent demo clips from screenshots when `ffmpeg` is installed:

```bash
node scripts/record-demo.js
bash scripts/assemble-video.sh
```

For a production sales video, record real Android/iOS device flows and follow `docs/VIDEO_SCRIPT.md` plus `docs/VOICEOVER_RECORDING_GUIDE.md`.

## 8. Troubleshooting

1. `JAVA_HOME` missing: install JDK 17 and export `JAVA_HOME`.
2. Android SDK missing: install Android command-line tools and platform 35.
3. Gradle dependency verification fails: regenerate verification metadata only after reviewing dependency changes.
4. `swift test` says `no such module XCTest`: install/select full Xcode.app; use `swift run PakFitCoreSmokeTests` for local smoke validation.
5. Screenshot gate fails for Pillow: set `PYTHON_CMD` to a Python with Pillow installed.
6. Release signing fails: provide all `PAKFIT_RELEASE_*` variables or leave all unset for unsigned local release evidence.
7. iOS signing fails in Xcode: configure Apple team, bundle ID, certificate, and provisioning profile externally.
8. Store listing gate fails: update `docs/store-listing.md` and matching release notes for the current version.
9. Photo privacy gate fails: keep food-photo workflows preview-only and avoid image-byte persistence/upload patterns.
10. Ports appear stuck: PakFit does not use fixed ports; run `bash scripts/dev-stop.sh` and inspect unrelated local tools.
