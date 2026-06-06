# Release and DevOps Plan

## Current Commands

Run tests:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
./gradlew testDebugUnitTest
```

Build debug APK:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
./gradlew assembleDebug
```

Build release APK and Android App Bundle:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
./gradlew assembleRelease bundleRelease
```

Production Android signing is configured only through external environment variables:

```bash
PAKFIT_RELEASE_STORE_FILE=/absolute/path/to/upload-keystore.jks
PAKFIT_RELEASE_STORE_PASSWORD=...
PAKFIT_RELEASE_KEY_ALIAS=...
PAKFIT_RELEASE_KEY_PASSWORD=...
```

## Local Release Gate

```bash
bash scripts/validate-release.sh
```

Export the built debug APK:

```bash
OUTPUT_DIR=/path/to/output bash scripts/export-android-debug-apk.sh
```

Export the built release APK and AAB:

```bash
OUTPUT_DIR=/path/to/output bash scripts/export-android-release-artifacts.sh
```

Generate release evidence:

```bash
REPORT_DIR=/path/to/reports bash scripts/generate-release-report.sh
```

## CI

- Run unit tests.
- Validate Android/iOS source version metadata alignment before building release artifacts.
- Validate Gradle Wrapper distribution checksum and wrapper JAR checksum.
- Validate resolved Gradle dependency artifacts with strict SHA-256 dependency verification metadata.
- Run Android debug and release lint.
- Generate dependency inventory and fail dynamic/SNAPSHOT dependency declarations.
- Build debug APK.
- Build release APK and Android App Bundle.
- Upload debug APK artifact.
- Upload release APK and AAB artifacts.
- Generate and upload release evidence report.
- Validate built Android APK metadata matches Android/iOS source version metadata.
- Run iOS Swift core smoke tests.
- Compile the SwiftUI app target.
- Run English-only source check.
- Run basic hardcoded secret-pattern smoke check.
- Validate iOS privacy manifest format and UserDefaults required-reason declaration.
- Validate Android Auto Backup is disabled and sensitive snapshot backup/data-extraction exclusions exist.
- Validate Android permissions are limited to the approved online search and food photo capture surface.
- Validate Android exported components are limited to the launcher activity.
- Validate food photo capture stays preview-only and image bytes are not persisted or uploaded by app code.
- Store APK artifact.
- Keep Android release minification and resource shrinking enabled.
- Keep signing secrets out of source control and inject Android release signing through secure CI/local environment variables.

## Release Gate

- Specs updated.
- Tests passing.
- Cross-platform version alignment gate passing.
- Android lint passing.
- Gradle Wrapper integrity gate passing.
- Strict Gradle dependency verification gate passing.
- Dependency inventory gate passing.
- Android permission privacy gate passing.
- Android exported surface gate passing.
- Food photo privacy gate passing.
- Debug APK, release APK, and release AAB build.
- Release APK uses R8 minification and resource shrinking.
- APK version metadata updated for meaningful MVP revisions.
- Health safety reviewed.
- Privacy/security notes reviewed.
- Android platform backup privacy gate passing.
- No secrets in repository.

## Acceptance Criteria

### Scenario: Android release artifacts are reproducible

Given a developer has Android SDK and Java configured
When they run the documented release validation command
Then debug APK, release APK, release AAB, and release evidence report artifacts are generated

### Scenario: Android and iOS versions stay aligned

Given the release validation command runs
When Android and iOS version metadata is inspected
Then Android versionName matches iOS MARKETING_VERSION
And Android versionCode matches iOS CURRENT_PROJECT_VERSION
And built Android APK metadata matches source version metadata

### Scenario: Release hardening is enforced

Given the Android release build runs
When validation completes
Then lintDebug and lintRelease have passed
And the release build uses R8 minification and resource shrinking

### Scenario: Dependency inventory is reproducible

Given the release validation command runs
When dependency inventory is generated
Then dynamic and SNAPSHOT dependencies are blocked
And Android and Swift dependency inventory files are recorded in release evidence

### Scenario: Gradle Wrapper is pinned and verified

Given the release validation command runs
When the build starts
Then the checked-in Gradle Wrapper pins Gradle 8.14.5
And the wrapper distribution SHA-256 and wrapper JAR SHA-256 are checked

### Scenario: Gradle dependencies are verified

Given the release validation command runs
When Gradle resolves Android/plugin artifacts
Then strict dependency verification checks committed SHA-256 metadata
And missing or changed resolved artifacts fail the release gate

### Scenario: Android permissions are minimized

Given the release validation command runs
When the Android manifest is inspected
Then only INTERNET and CAMERA permissions are allowed
And camera hardware remains optional for install compatibility

### Scenario: Food photos stay ephemeral

Given the release validation command runs
When Android and iOS photo workflow sources are inspected
Then food photo capture remains preview-only
And image-byte persistence or upload patterns fail the gate

### Scenario: Android exported surface is minimized

Given the release validation command runs
When the Android manifest is inspected
Then only the launcher MainActivity is exported
And services, receivers, providers, or activity aliases fail the gate until a security review spec exists
