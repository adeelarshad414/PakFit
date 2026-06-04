# Non-Functional Requirements

## Performance

- On-device plan generation should complete instantly for simple profile changes.
- UI should remain responsive while sliders and chips are adjusted.
- Adding lifestyle modes should not introduce network dependency or noticeable delay.
- Food catalog filtering, manual item entry, and record summaries should remain responsive on-device.
- Dashboard, chart, trend, todo, and history calculations should update instantly from in-memory records.

## Reliability

- Domain recommendation logic must be testable without Android framework dependencies.
- Build and test commands must be documented.

## Accessibility

- Touch targets should be easy to tap.
- Text should remain readable with larger font settings.
- Safety warnings should not rely on color alone.
- Multi-select chips should show selected state through text/shape/color, not color alone.
- Charts must include numeric labels so they remain understandable without color alone.

## Maintainability

- Recommendation logic belongs in the domain layer.
- UI should consume structured results instead of parsing strings.
- New health rules require specs and tests.
- New lifestyle modes require rule tests and should not be hardcoded only in UI.
- Dashboard analytics must live in pure Kotlin domain code, with Compose only rendering chart data and dashboard state.

## Privacy

- Current lifestyle and medical-caution data remains in memory only.
- Current health marker values and meal records remain in memory only.
- No analytics are emitted until consent and privacy specs are implemented.

## Acceptance Criteria

### Scenario: Domain tests run without emulator

Given a developer runs unit tests  
When domain tests execute  
Then they do not require an Android emulator

### Scenario: Build produces debug APK

Given the repository is configured  
When the debug build runs  
Then it produces an installable APK

### Scenario: New lifestyle features stay offline-first

Given a user selects Ramadan, daawat, budget, office, or eating-out mode  
When the app generates a plan  
Then the app does not require a backend call

### Scenario: Health and meal records stay local

Given a user enters lab values or food records  
When the MVP calculates reports  
Then no backend, analytics, or external storage is required

### Scenario: Charts stay local

Given the dashboard renders charts and progress  
When data changes  
Then no external charting API or network call is required
