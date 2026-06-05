# Spec 030 - Release Hardening, Lint, and R8

## Objective

Move PakFit's Android delivery path closer to production readiness by enforcing Android lint, enabling release minification/resource shrinking, and recording optimization evidence in every release report.

## Functional Requirements

- Android release builds must enable R8 minification.
- Android release builds must enable resource shrinking.
- Release builds must use Android's optimized default ProGuard file plus `app/proguard-rules.pro`.
- Local release validation must run `lintDebug` and `lintRelease` before artifacts are accepted.
- CI must run Android unit tests, lint, debug APK, release APK, and release AAB generation.
- Release evidence must report R8 minification status, resource shrinking status, ProGuard/R8 rule status, and mapping checksum when present.
- Android version metadata must be bumped for this release-hardening iteration.
- iOS Xcode marketing/build version should stay aligned with the release iteration even though archive/signing requires full Xcode and signing assets.

## Non-Functional Requirements

- ProGuard rules should stay narrow so the release build benefits from shrinking and obfuscation.
- Release hardening must not introduce backend services, analytics credentials, signing secrets, or cloud dependencies.
- Validation must remain runnable on a local machine with Android SDK, JDK 17, Swift, and the existing Gradle cache.
- The report must keep stating that unsigned local artifacts are build evidence, not store-submission proof.

## Acceptance Evidence

- `app/build.gradle.kts` has `isMinifyEnabled = true` and `isShrinkResources = true` for the release build.
- `app/proguard-rules.pro` exists and is wired into release builds.
- `scripts/validate-release.sh` runs `testDebugUnitTest`, `lintDebug`, `lintRelease`, `assembleDebug`, `assembleRelease`, and `bundleRelease`.
- `scripts/generate-release-report.sh` records minification, shrinking, and mapping checksum evidence.
- `.github/workflows/pakfit-ci.yml` runs Android lint before uploading artifacts.
- `bash scripts/validate-release.sh` passes locally.

## Release Boundary

This spec proves release optimization and lint gating. It still does not prove Play Store submission because production upload-key signing, Play Console validation, and store listing review remain external gates.
