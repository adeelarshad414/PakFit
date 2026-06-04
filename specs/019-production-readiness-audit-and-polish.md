# Production Readiness Audit and Polish

## Executive Summary

PakFit is currently an Android-only MVP with strong local domain logic for Pakistani nutrition, workouts, health screening, analysis, and calorie tracking. The app is useful, but its prior UI placed too many workflows in one long scroll. A production-grade experience needs clearer task separation, stronger hierarchy, better status summaries, and honest backend readiness planning.

This slice improves the Android frontend workflow and documents the backend/frontend gaps that still need separate implementation.

## Audit Findings

### UI/UX Findings

- The app has too many cards on one screen, creating high cognitive load.
- Setup, health review, meal logging, dashboard analysis, and plan review are mixed together.
- Daily use should prioritize dashboard and food tracking, while setup and health markers should be secondary workflows.
- Light/dark mode exists, but warning and progress states need to consistently use theme-aware colors.
- Health and crisis copy should stay calm, concise, and English-only.

### Frontend Architecture Findings

- Compose UI is single-file MVP code. This is acceptable for the current repo size, but production should split screens/components by workflow.
- State is in-memory only. This is fine for MVP demos, but production requires persistence, restore, and migration strategy.
- No Compose UI test framework is currently configured.
- Charts are local composables, not a charting library. That keeps dependencies low, but future production analytics may need richer visualization primitives.

### Backend Findings

No backend service exists in this repository. Production backend work must not be claimed until built.

Required backend capabilities for production:

- User identity and consent management.
- Encrypted profile, food log, lab marker, and health screening storage.
- Sync APIs for daily logs, plans, dashboards, and reports.
- Audit logs for health-sensitive events.
- Clinical content versioning and medical disclaimer governance.
- Secure admin CMS for food catalog, health thresholds, and plan rules.
- Observability, alerting, rate limiting, backups, and disaster recovery.
- Data export/delete workflows.

### Security and Privacy Findings

- The MVP has no network permissions and stores data only in memory.
- Production must add encrypted local storage, secure transport, auth, authorization, and privacy controls before handling real user data at scale.
- Mental wellness and metabolic data are sensitive health data and should be treated as high-risk.

## In-App Improvements for This Slice

- Add workflow navigation:
  - Dashboard
  - Tracker
  - Health
  - Plan
  - Setup
- Make Dashboard the default daily-use surface.
- Add a compact today overview with calories, burn, net calories, meals, health flags, and adherence.
- Keep Tracker focused on catalog, manual entry, meal/hour logging, hourly breakdown, meal totals, and history.
- Keep Health focused on medical cautions, markers, BMI/report flags, clinical insights, and mental wellness.
- Keep Plan focused on goals, routine, diet, training place, lifestyle modes, equipment, safety warnings, and plan details.
- Keep Setup focused on demographics and body metrics.
- Use theme-aware colors for progress and warning states.
- Bump the APK version after successful test/build.

## Non-Functional Requirements

- The app must continue to compile offline with the existing Gradle setup.
- Domain tests must continue to pass.
- The app must not add a fake backend or fake AI service.
- No new permissions are required for this polish slice.
- The UI must remain English-only.

## Acceptance Criteria

### Scenario: Daily workflow starts at dashboard

Given the app opens  
When the first screen is shown  
Then the dashboard workflow is selected  
And the user sees today summary, progress, trends, todos, and history before editing deeper setup fields

### Scenario: Tracker workflow is focused

Given the user selects Tracker  
When the screen is displayed  
Then the user sees food catalog, manual food entry, meal logging, hourly totals, meal-wise totals, and newest-first history

### Scenario: Health workflow is focused

Given the user selects Health  
When the screen is displayed  
Then the user sees medical cautions, health markers, BMI/report flags, clinical insights, mental wellness, and crisis support without food catalog clutter

### Scenario: Plan workflow is focused

Given the user selects Plan  
When the screen is displayed  
Then goal, routine, diet, training place, lifestyle modes, equipment, safety warnings, and the generated plan are together

### Scenario: Backend readiness is documented honestly

Given the repository has no backend  
When production readiness is reviewed  
Then backend gaps are documented as future work and not represented as completed product behavior
