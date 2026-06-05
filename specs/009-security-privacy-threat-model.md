# Security Privacy Threat Model

## Current Data

The current app stores user data only in an explicit local snapshot after required consent acknowledgements are complete. The saved snapshot is protected at rest with platform secure storage and sends no data to a backend.

## Sensitive Data Classes

- Health profile data
- Medical cautions
- Weight, height, age, gender
- Goals and progress history
- Food logs, custom foods, calories, lifestyle inputs, health markers, mental wellness inputs, clinical risk factors, and consent state
- Future analytics events if a later explicit opt-in and schema are implemented

## Threats

- Sensitive health data leaked through logs.
- Hardcoded API keys or secrets.
- Over-collection of analytics.
- Unsafe AI-generated health advice if future AI features are added.
- Unauthorized access if backend accounts are added.

## Controls

- Do not log profile or medical caution values.
- Do not add secrets to the repository.
- Keep analytics off until consent and schema specs exist.
- Block local save/export until the required consent and clinical-boundary acknowledgements are complete.
- Protect saved local snapshots at rest using Android Keystore-backed encryption on Android and Keychain-backed storage on iOS.
- Disable Android Auto Backup and exclude sensitive local snapshot storage from Android backup/data-extraction rules.
- Pin the Gradle Wrapper distribution and verify wrapper JAR/distribution checksums in release validation.
- Generate an offline dependency inventory and block dynamic/SNAPSHOT dependencies in release validation.
- Keep food photo image bytes out of the local snapshot.
- Keep recommendation rules deterministic and testable for the current slice.
- Add backend auth and storage threat model before introducing APIs.

## Acceptance Criteria

### Scenario: No backend data leakage in current MVP

Given the current app runs  
When a user changes profile inputs, health markers, food logs, or mental wellness inputs  
Then no network call is made  
And no sensitive values are logged by app code  
And local save/export remains blocked until required consent is complete
