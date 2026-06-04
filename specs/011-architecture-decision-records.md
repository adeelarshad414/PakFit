# Architecture Decision Records

## ADR 001: Keep recommendation logic in pure Kotlin domain layer

Decision: Keep calorie, nutrition, workout, and safety-warning logic outside Compose UI.

Reason:

- Domain logic can be tested without emulator.
- UI can remain a renderer of structured state.
- Health rules are easier to review when isolated.

## ADR 002: Keep current MVP offline-first

Decision: Do not introduce backend, persistence, or analytics in the safety slice.

Reason:

- The first priority is safe, tested recommendation behavior.
- Avoid collecting sensitive health data before privacy controls exist.

## ADR 003: Use structured warnings

Decision: `PlanRecommendation` contains `plan` and `warnings`.

Reason:

- Warning content should be separate from coaching content.
- UI can prioritize warnings without parsing strings.

## Acceptance Criteria

### Scenario: UI does not own health rules

Given a safety rule changes  
When implementation is updated  
Then the rule changes in domain code and domain tests  
And UI only renders structured result data
