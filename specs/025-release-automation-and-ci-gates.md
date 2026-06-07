# Spec 025 - Release Automation and CI Gates

## Objective

Move PakFit from manual-only validation toward repeatable production release evidence for Android and iOS. The repository must include local validation scripts and CI gates that can prove tests, APK/AAB builds, Swift/iOS compile, source-language policy, and basic secret hygiene.

## Functional Requirements

- Provide a local release validation script that runs Android unit tests, Android debug/release lint, builds debug APK, release APK, and release AAB artifacts, runs the iOS Swift smoke suite, compiles the SwiftUI app target, and checks English-only app source.
- Validate Android and iOS source version metadata alignment before release builds run.
- Validate Android and iOS app identity metadata before release evidence is accepted.
- Validate Android and iOS app icon assets before release evidence is accepted.
- Validate Android and iOS platform compatibility metadata before release evidence is accepted.
- Validate Android build toolchain compatibility before release evidence is accepted.
- Validate Gradle Wrapper integrity before Android release tasks run.
- Validate resolved Gradle dependency artifacts against committed SHA-256 verification metadata.
- Validate Android permission minimization for online search and food photo capture before release evidence is accepted.
- Validate iOS permission purpose-string posture before release evidence is accepted.
- Validate Android exported component surface before release evidence is accepted.
- Validate Android network security posture before release evidence is accepted.
- Validate iOS network security posture before release evidence is accepted.
- Validate food photo privacy posture before release evidence is accepted.
- Validate store listing and release notes before release evidence is accepted.
- Validate generated store screenshot previews before release evidence is accepted.
- Validate Android release signing hygiene before release evidence is accepted.
- Validate iOS signing hygiene before release evidence is accepted.
- Validate store privacy disclosure consistency before release evidence is accepted.
- Validate dependency advisory monitoring configuration before release evidence is accepted.
- Validate security governance before release evidence is accepted.
- Validate accessibility and readability posture before release evidence is accepted.
- Validate diagnostic privacy before release evidence is accepted.
- Validate adult-use safety before release evidence is accepted.
- Validate iOS setup parity before release evidence is accepted.
- Validate iOS health marker parity before release evidence is accepted.
- Validate iOS lifestyle coach parity before release evidence is accepted.
- Validate iOS clinical and mental wellness parity before release evidence is accepted.
- Validate PCOS clinical safety before release evidence is accepted.
- Validate pregnancy plan safety before release evidence is accepted.
- Validate blood pressure plan safety before release evidence is accepted.
- Validate kidney plan safety before release evidence is accepted.
- Validate diabetes medication plan safety before release evidence is accepted.
- Validate iOS analysis dashboard parity before release evidence is accepted.
- Validate iOS application handoff artifact export before release evidence is accepted.
- Provide export scripts that copy the built debug APK, release APK, release AAB, and iOS application handoff archive to versioned destinations using build metadata.
- Add GitHub Actions CI for Android unit tests, lint, debug APK, release APK, and release AAB artifact upload.
- Add dependency inventory generation and artifact upload to CI.
- Add dependency advisory monitoring configuration validation to CI.
- Add security governance validation to CI.
- Add accessibility and readability validation to CI.
- Add diagnostic privacy validation to CI.
- Add adult-use safety validation to CI.
- Add iOS setup parity validation to CI.
- Add iOS health marker parity validation to CI.
- Add iOS lifestyle coach parity validation to CI.
- Add iOS clinical and mental wellness parity validation to CI.
- Add PCOS clinical safety validation to CI.
- Add pregnancy plan safety validation to CI.
- Add blood pressure plan safety validation to CI.
- Add kidney plan safety validation to CI.
- Add diabetes medication plan safety validation to CI.
- Add iOS analysis dashboard parity validation to CI.
- Add iOS application handoff artifact validation and upload to CI.
- Add GitHub Actions CI for iOS Swift smoke tests and SwiftUI app target compile.
- Add source quality gates for English-only app source and obvious hardcoded secret patterns.
- Add platform privacy gates for iOS privacy manifest, iOS permission privacy, iOS network security, iOS signing hygiene, Android backup/data-extraction posture, Android permission minimization, Android exported surface, Android network security, food photo privacy, store listing/release notes, store privacy disclosure consistency, generated screenshot previews, and Android release signing hygiene.
- Add Dependabot coverage validation for Gradle, Swift Package Manager, and GitHub Actions.

## Non-Functional Requirements

- CI must not require backend services, production signing secrets, analytics credentials, or cloud health data.
- Android artifact uploads must use generated build output only.
- Release signing secrets must stay outside the repository and be injected through secure environment variables only when a production upload keystore exists.
- iOS App Store archive/signing remains blocked until full Xcode and signing assets are available; the local handoff artifact is review evidence only.

## Acceptance Evidence

- `scripts/validate-release.sh` passes locally.
- Gradle Wrapper integrity is part of the required validation path.
- Android/iOS version alignment is part of the required validation path.
- App identity metadata validation is part of the required validation path.
- App icon asset validation is part of the required validation path.
- Platform compatibility validation is part of the required validation path.
- Android build toolchain validation is part of the required validation path.
- Strict Gradle dependency verification is part of the required validation path.
- `lintDebug` and `lintRelease` are part of the required validation path.
- Android Auto Backup and sensitive snapshot backup/data-extraction exclusions are part of the required validation path.
- Android permission minimization is part of the required validation path.
- iOS permission privacy is part of the required validation path.
- Android exported surface minimization is part of the required validation path.
- Android network security is part of the required validation path.
- iOS network security is part of the required validation path.
- Food photo privacy is part of the required validation path.
- Store listing and release notes are part of the required validation path.
- Store screenshot previews are part of the required validation path.
- Android release signing hygiene is part of the required validation path.
- iOS signing hygiene is part of the required validation path.
- Store privacy disclosure consistency is part of the required validation path.
- Dependency advisory monitoring configuration is part of the required validation path.
- Security governance is part of the required validation path.
- Accessibility and readability validation is part of the required validation path.
- Diagnostic privacy validation is part of the required validation path.
- Adult-use safety validation is part of the required validation path.
- iOS setup parity validation is part of the required validation path.
- iOS health marker parity validation is part of the required validation path.
- iOS lifestyle coach parity validation is part of the required validation path.
- iOS clinical and mental wellness parity validation is part of the required validation path.
- PCOS clinical safety validation is part of the required validation path.
- Pregnancy plan safety validation is part of the required validation path.
- Blood pressure plan safety validation is part of the required validation path.
- Kidney plan safety validation is part of the required validation path.
- Diabetes medication plan safety validation is part of the required validation path.
- iOS analysis dashboard parity validation is part of the required validation path.
- iOS application handoff artifact validation is part of the required validation path.
- Dependency inventory and dynamic/SNAPSHOT dependency blocking are part of the required validation path.
- `scripts/export-android-debug-apk.sh` can export a versioned debug APK after validation.
- `scripts/export-android-release-artifacts.sh` can export versioned release APK and AAB artifacts after validation.
- `scripts/export-ios-app-handoff.sh` can export a versioned iOS application handoff artifact after validation.
- `.github/workflows/pakfit-ci.yml` defines Android, iOS Swift, and source-gate jobs.
- README and release spec document the repeatable gates.
