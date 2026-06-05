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
- Validate Gradle Wrapper distribution checksum and wrapper JAR checksum.
- Run Android debug and release lint.
- Generate dependency inventory and fail dynamic/SNAPSHOT dependency declarations.
- Build debug APK.
- Build release APK and Android App Bundle.
- Upload debug APK artifact.
- Upload release APK and AAB artifacts.
- Generate and upload release evidence report.
- Run iOS Swift core smoke tests.
- Compile the SwiftUI app target.
- Run English-only source check.
- Run basic hardcoded secret-pattern smoke check.
- Validate iOS privacy manifest format and UserDefaults required-reason declaration.
- Validate Android Auto Backup is disabled and sensitive snapshot backup/data-extraction exclusions exist.
- Store APK artifact.
- Keep Android release minification and resource shrinking enabled.
- Keep signing secrets out of source control and inject Android release signing through secure CI/local environment variables.

## Release Gate

- Specs updated.
- Tests passing.
- Android lint passing.
- Gradle Wrapper integrity gate passing.
- Dependency inventory gate passing.
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
