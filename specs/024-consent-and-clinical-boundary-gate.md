# Spec 024 - Consent and Clinical Boundary Gate

## Objective

Add a production-grade consent gate before PakFit saves or exports sensitive local health snapshots. The app must make the user acknowledge local health data storage, medical boundaries, mental-health crisis boundaries, photo calorie estimate limits, and local-only storage.

## Functional Requirements

- Show required consent acknowledgements in the local data/privacy area.
- Block save/export of sensitive local snapshots until all required acknowledgements are accepted.
- Keep restore and clear available so users can recover or remove existing local data.
- Persist the consent state and consent version inside the local snapshot.
- Keep analytics off unless a future explicit opt-in, schema, and privacy notice are implemented.
- Add the same consent governance model to Android and iOS.

## Required Acknowledgements

- Sensitive health data storage.
- Screening and coaching are not diagnosis, treatment, prescription, or clinician replacement.
- Mental wellness screeners are not crisis or emergency care.
- Food photo calorie estimates are approximate until a reviewed vision model/backend exists.
- Current storage is local-only with no cloud account or sync.

## Non-Functional Requirements

- Consent logic must live in deterministic domain/core code with tests.
- Consent copy must remain English-only and calm.
- No network calls, analytics events, or hidden data sharing should be introduced.
- Consent should be versioned for future migration.

## Acceptance Evidence

- Android domain tests verify incomplete consent blocks local health snapshot storage.
- Android snapshot tests verify consent metadata round-trips.
- iOS smoke/XCTest coverage verifies consent gate behavior and snapshot consent metadata.
- Android `testDebugUnitTest assembleDebug` passes.
- iOS `swift run PakFitCoreSmokeTests` and `swift build --target PakFitApp` pass.
