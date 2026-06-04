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

## Future CI

- Run unit tests.
- Run lint.
- Build debug APK.
- Run dependency vulnerability scan.
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
