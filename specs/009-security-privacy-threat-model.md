# Security Privacy Threat Model

## Current Data

The current app stores no user data and sends no data to a backend. Profile values exist only in memory.

## Sensitive Data Classes

- Health profile data
- Medical cautions
- Weight, height, age, gender
- Goals and progress history
- Future analytics events

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
- Keep recommendation rules deterministic and testable for the current slice.
- Add backend auth and storage threat model before introducing APIs.

## Acceptance Criteria

### Scenario: No backend data leakage in current MVP

Given the current app runs  
When a user changes profile inputs  
Then no network call is made  
And no sensitive values are logged by app code
