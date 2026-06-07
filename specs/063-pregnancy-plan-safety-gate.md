# Spec 063: Pregnancy Plan Safety Gate

## Objective

Make pregnancy a plan-modifying safety state rather than only a warning. PakFit must not present ordinary fat-loss calorie deficits or high-intensity workout plans when pregnancy is selected.

## Functional Requirements

- Android and iOS recommendation engines must detect `Pregnancy` medical caution before calculating nutrition and workout output.
- Pregnancy must pause weight-loss calorie deficits and muscle-gain surplus logic.
- Pregnancy must use conservative protein target logic rather than goal-escalated fat-loss/muscle-gain multipliers.
- Pregnancy meal guidance must direct users to obstetric clinician review, steady meals, safe hydration, and prenatal nutrition discussion.
- Pregnancy workout output must switch to clinician-cleared gentle movement with stop-warning symptoms.
- Pregnancy plan focus must include `Pregnancy safety review`.
- Existing structured pregnancy medical-review warning must remain visible.

## Non-Functional Requirements

- The implementation must be deterministic and covered by Android unit tests plus iOS smoke/XCTest coverage.
- The app must not diagnose pregnancy complications, prescribe prenatal nutrition, prescribe supplements, prescribe exercise, or replace obstetric care.
- The gate must not add permissions, analytics, backend services, remote uploads, or account requirements.
- Official source categories must reference ACOG pregnancy physical activity and healthy eating guidance.

## Acceptance Evidence

- Android unit tests prove pregnancy removes a fat-loss calorie deficit, removes fat-loss workout labeling, adds clinician guidance, and keeps the pregnancy warning.
- iOS smoke and XCTest coverage prove the same behavior.
- `bash scripts/validate-pregnancy-plan-safety.sh` passes locally and in CI.
- `bash scripts/validate-release.sh` runs the pregnancy plan safety gate.
- Generated release evidence includes pregnancy plan safety gate status and documentation checksum.

## Release Boundary

This gate provides conservative app behavior for pregnancy caution. Final public release still requires obstetric/clinical copy review, device QA, legal/privacy review, and store age-suitability review.
