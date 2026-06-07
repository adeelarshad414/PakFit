# PakFit Commands Quick Reference

PakFit is a native Android/iOS application. It does not start a backend, web frontend, database, Redis, Expo, or Metro service in the current build.

## Terminal / Codex

| Action | Command |
| --- | --- |
| Start local native validation | `bash scripts/dev-start.sh` |
| Stop tracked dev processes | `bash scripts/dev-stop.sh` |
| Restart validation | `bash scripts/dev-restart.sh` |
| Android unit tests | `./gradlew --dependency-verification strict testDebugUnitTest` |
| Android debug APK | `./gradlew --dependency-verification strict assembleDebug` |
| Android release APK/AAB | `./gradlew --dependency-verification strict assembleRelease bundleRelease` |
| Full release validation | `bash scripts/validate-release.sh` |
| Export debug APK | `OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-android-debug-apk.sh` |
| Export release APK/AAB | `OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-android-release-artifacts.sh` |
| Swift smoke tests | `cd ios/PakFitIOS && swift run PakFitCoreSmokeTests` |
| SwiftUI target compile | `cd ios/PakFitIOS && swift build --target PakFitApp` |
| Optional XCTest runner | `cd ios/PakFitIOS && swift test` |
| Export iOS handoff archive | `OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-ios-app-handoff.sh` |
| Capture screenshots | `node scripts/capture-screenshots.js` |
| Record silent demo clips from screenshots | `node scripts/record-demo.js` |
| Assemble demo video | `bash scripts/assemble-video.sh` |
| View Android dev log | `tail -f logs/android-dev.log` |
| View iOS dev log | `tail -f logs/ios-dev.log` |
| View all logs | `tail -f logs/*.log` |

## VS Code

| Action | How |
| --- | --- |
| Start native validation | Terminal > Run Task > Start PakFit Native Validation |
| Stop tracked processes | Terminal > Run Task > Stop PakFit Dev Processes |
| Restart validation | Terminal > Run Task > Restart PakFit Native Validation |
| Run full release validation | Terminal > Run Task > Run Release Validation |
| Capture screenshots | Terminal > Run Task > Capture Screenshots |
| Record demo video | Terminal > Run Task > Record Demo Video |

## Android Device Testing

| Action | Command |
| --- | --- |
| List connected devices | `adb devices` |
| Install debug APK | `adb install -r app/build/outputs/apk/debug/app-debug.apk` |
| Install exported APK | `adb install -r /Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit/PakFit-v0.52.0-debug.apk` |
| Launch app | `adb shell monkey -p com.pakfit.app 1` |
| View app logs | `adb logcat | grep PakFit` |

## iOS Device/Simulator Testing

| Action | Command |
| --- | --- |
| Open project | `open ios/PakFitIOS/PakFitIOS.xcodeproj` |
| Build Swift package smoke target | `cd ios/PakFitIOS && swift run PakFitCoreSmokeTests` |
| Compile SwiftUI target | `cd ios/PakFitIOS && swift build --target PakFitApp` |
| Create source handoff archive | `bash scripts/export-ios-app-handoff.sh` |

Signed IPA, TestFlight, App Store archive validation, provisioning profiles, and Apple certificates remain external release boundaries.

## Stop And Kill

| Action | Command |
| --- | --- |
| Recommended cleanup | `bash scripts/dev-stop.sh` |
| Stop Gradle daemon too | `PAKFIT_DEV_STOP_GRADLE_DAEMON=1 bash scripts/dev-stop.sh` |
| Kill one stuck port on macOS/Linux | `lsof -ti:3000 | xargs kill -9` |
| Check one port on macOS/Linux | `lsof -i :3000` |
| Windows find process by port | `netstat -ano | findstr :3000` |
| Windows kill process by PID | `taskkill /PID <pid> /F` |
| Stop Docker services if you started any externally | `docker compose down` |

PakFit does not bind fixed local ports in its native validation workflow. Use port-kill commands only for unrelated tools you started manually.

## Logs

| Action | Command |
| --- | --- |
| Watch all logs | `tail -f logs/*.log` |
| Android validation log | `tail -f logs/android-dev.log` |
| iOS validation log | `tail -f logs/ios-dev.log` |
| Last 100 Android log lines | `tail -100 logs/android-dev.log` |
| Search logs for errors | `grep -i "error\\|exception\\|failed" logs/*.log` |
| Clear dev logs | `: > logs/android-dev.log && : > logs/ios-dev.log` |
