# Spec 066 - Diabetes Medication Plan Safety Gate

## Objective

Make diabetes medication caution plan-aware across Android and iOS. A selected caution must not only show a warning; it must also pause aggressive calorie targets, add glucose-aware meal timing, avoid hard fasted training guidance, and keep medication decisions outside PakFit.

## Functional Requirements

- Add Android and iOS diabetes medication caution flags inside the recommendation engines.
- Pause ordinary fat-loss calorie deficits and muscle-gain calorie surpluses when diabetes medication caution is selected.
- Keep structured `MEDICAL_REVIEW` warnings for diabetes medication, including Ramadan-specific source categories when Ramadan fasting is active.
- Add meal guidance for consistent roti, rice, fruit, dates, dessert, and sweet-drink carbohydrate portions.
- Add explicit medicine boundary copy: users must not self-adjust diabetes medicines from app guidance.
- Add low-glucose symptom and urgent-care boundary copy.
- Add Ramadan timing guidance for clinician-reviewed suhoor, iftar, hydration, glucose checks, medication timing, and avoiding hard fasted training.
- Switch workout title to diabetes medication clinician-reviewed movement and remove fat-loss or muscle-gain labels.
- Add Android unit, Swift smoke, and Swift XCTest coverage.
- Add a static validation script wired into release validation, CI, release evidence, README, store listing, and release notes.

## Non-Functional Requirements

- The app must remain local-first and must not store or upload glucose readings in this gate.
- The app must remain English-only.
- The gate must avoid diagnosis, treatment, prescribing, reversal, guaranteed safety, and clinician-replacement claims.

## Acceptance Evidence

- `scripts/validate-diabetes-medication-plan-safety.sh` passes.
- Android unit tests assert the calorie pause, plan title, Ramadan source, meal timing, low-glucose boundary, medicine boundary, and plan focus.
- Swift smoke tests assert the same behavior for iOS release evidence.
- Swift XCTest source includes the same coverage for full Xcode runners.
- `scripts/validate-release.sh` includes the diabetes medication plan safety gate.
- `.github/workflows/pakfit-ci.yml` includes the diabetes medication plan safety gate.
- `scripts/generate-release-report.sh` reports diabetes medication plan safety documentation, checksum, gate status, policy, and manual review boundary.

## Acceptance Criteria

### Scenario: Diabetes medication modifies plan output

Given the user selects diabetes medication and fat loss  
When the recommendation engine builds a plan  
Then the plan pauses the ordinary fat-loss calorie deficit  
And the workout title uses diabetes medication clinician-reviewed movement  
And the workout title does not present fat loss

### Scenario: Ramadan diabetes medication guidance stays clinician-reviewed

Given the user selects Ramadan fasting and diabetes medication  
When the recommendation engine builds a plan  
Then meal timing mentions suhoor and iftar clinician review  
And guidance avoids hard fasted training  
And the warning source references Ramadan diabetes guidance

### Scenario: Medicine boundary is preserved

Given the user selects diabetes medication  
When the recommendation engine builds meal and workout guidance  
Then the guidance tells users not to self-adjust diabetes medicines from app guidance  
And the app does not prescribe insulin, oral medicines, or personal glucose targets
