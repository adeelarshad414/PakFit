# Release and DevOps Plan

## Current Commands

Run tests:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
/opt/homebrew/opt/gradle@8/bin/gradle testDebugUnitTest
```

Build debug APK:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
/opt/homebrew/opt/gradle@8/bin/gradle assembleDebug
```

## Local Release Gate

```bash
bash scripts/validate-release.sh
```

Export the built debug APK:

```bash
OUTPUT_DIR=/path/to/output bash scripts/export-android-debug-apk.sh
```

## CI

- Run unit tests.
- Build debug APK.
- Upload debug APK artifact.
- Run iOS Swift core smoke tests.
- Compile the SwiftUI app target.
- Run English-only source check.
- Run basic hardcoded secret-pattern smoke check.
- Validate iOS privacy manifest format and UserDefaults required-reason declaration.
- Store APK artifact.
- Add release signing only after secure secret storage is configured.

## Release Gate

- Specs updated.
- Tests passing.
- APK builds.
- APK version metadata updated for meaningful MVP revisions.
- Health safety reviewed.
- Privacy/security notes reviewed.
- No secrets in repository.

## Acceptance Criteria

### Scenario: Debug release is reproducible

Given a developer has Android SDK and Java configured  
When they run the documented build command  
Then a debug APK is generated
