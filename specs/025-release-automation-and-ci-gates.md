# Spec 025 - Release Automation and CI Gates

## Objective

Move PakFit from manual-only validation toward repeatable production release evidence for Android and iOS. The repository must include local validation scripts and CI gates that can prove tests, APK/AAB builds, Swift/iOS compile, source-language policy, and basic secret hygiene.

## Functional Requirements

- Provide a local release validation script that runs Android unit tests, Android debug/release lint, builds debug APK, release APK, and release AAB artifacts, runs the iOS Swift smoke suite, compiles the SwiftUI app target, and checks English-only app source.
- Validate Android and iOS source version metadata alignment before release builds run.
- Validate Android and iOS app icon assets before release evidence is accepted.
- Validate Gradle Wrapper integrity before Android release tasks run.
- Validate resolved Gradle dependency artifacts against committed SHA-256 verification metadata.
- Validate Android permission minimization for online search and food photo capture before release evidence is accepted.
- Validate iOS permission purpose-string posture before release evidence is accepted.
- Validate Android exported component surface before release evidence is accepted.
- Validate Android network security posture before release evidence is accepted.
- Validate iOS network security posture before release evidence is accepted.
- Validate food photo privacy posture before release evidence is accepted.
- Provide export scripts that copy the built debug APK, release APK, and release AAB to versioned destinations using build metadata.
- Add GitHub Actions CI for Android unit tests, lint, debug APK, release APK, and release AAB artifact upload.
- Add dependency inventory generation and artifact upload to CI.
- Add GitHub Actions CI for iOS Swift smoke tests and SwiftUI app target compile.
- Add source quality gates for English-only app source and obvious hardcoded secret patterns.
- Add platform privacy gates for iOS privacy manifest, iOS permission privacy, iOS network security, Android backup/data-extraction posture, Android permission minimization, Android exported surface, Android network security, and food photo privacy.

## Non-Functional Requirements

- CI must not require backend services, production signing secrets, analytics credentials, or cloud health data.
- Android artifact uploads must use generated build output only.
- Release signing secrets must stay outside the repository and be injected through secure environment variables only when a production upload keystore exists.
- iOS App Store archive/signing remains blocked until full Xcode and signing assets are available.

## Acceptance Evidence

- `scripts/validate-release.sh` passes locally.
- Gradle Wrapper integrity is part of the required validation path.
- Android/iOS version alignment is part of the required validation path.
- App icon asset validation is part of the required validation path.
- Strict Gradle dependency verification is part of the required validation path.
- `lintDebug` and `lintRelease` are part of the required validation path.
- Android Auto Backup and sensitive snapshot backup/data-extraction exclusions are part of the required validation path.
- Android permission minimization is part of the required validation path.
- iOS permission privacy is part of the required validation path.
- Android exported surface minimization is part of the required validation path.
- Android network security is part of the required validation path.
- iOS network security is part of the required validation path.
- Food photo privacy is part of the required validation path.
- Dependency inventory and dynamic/SNAPSHOT dependency blocking are part of the required validation path.
- `scripts/export-android-debug-apk.sh` can export a versioned debug APK after validation.
- `scripts/export-android-release-artifacts.sh` can export versioned release APK and AAB artifacts after validation.
- `.github/workflows/pakfit-ci.yml` defines Android, iOS Swift, and source-gate jobs.
- README and release spec document the repeatable gates.
