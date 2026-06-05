# Spec 029 - Android Release Artifacts and Signing

## Objective

Advance PakFit's Android release readiness by producing repeatable release APK and Android App Bundle artifacts, documenting secure signing inputs, and making CI/reporting verify the release artifact path without committing signing secrets.

## Functional Requirements

- Build `assembleRelease` and `bundleRelease` as part of the local release validation gate.
- Export the latest release APK and release AAB into the ignored output folder with versioned filenames.
- Generate release evidence that includes debug APK, release APK, release AAB, checksums, sizes, and signing status.
- Upload debug APK, release APK, release AAB, and release evidence report artifacts from CI.
- Support production Android signing through external environment variables:
  - `PAKFIT_RELEASE_STORE_FILE`
  - `PAKFIT_RELEASE_STORE_PASSWORD`
  - `PAKFIT_RELEASE_KEY_ALIAS`
  - `PAKFIT_RELEASE_KEY_PASSWORD`
- Fail Gradle configuration when only a partial release signing environment is provided.

## Non-Functional Requirements

- Signing credentials must never be committed to the repository.
- Local release validation must still run without production signing secrets and must clearly label unsigned artifacts.
- Release reporting must not require backend services, analytics keys, cloud services, or Play Console credentials.
- The workflow must remain reproducible on CI and local developer machines with Android SDK and JDK 17.

## Acceptance Evidence

- `scripts/validate-release.sh` runs Android unit tests plus `assembleDebug`, `assembleRelease`, and `bundleRelease`.
- `scripts/export-android-release-artifacts.sh` copies versioned release APK and AAB files to the output folder.
- `scripts/generate-release-report.sh` records release APK and AAB SHA-256 values.
- `.github/workflows/pakfit-ci.yml` uploads debug APK, release APK, release AAB, and release evidence artifacts.
- `app/build.gradle.kts` configures release signing only when all required `PAKFIT_RELEASE_*` variables are present.

## Release Boundary

This spec proves repeatable release artifact generation and secure signing readiness. It does not prove Play Store production submission until a real upload keystore, Play Console app, store listing, and track validation are available.
