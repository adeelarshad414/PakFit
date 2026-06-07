# Spec 062: PCOS Clinical Safety Gate

## Objective

Add non-diagnostic PCOS metabolic and reproductive screening support for Pakistani users while keeping medication, fertility, diagnosis, and treatment decisions outside the app.

## Functional Requirements

- Add clinical risk factors for irregular or missed periods, excess hair or persistent acne, and known PCOS.
- Add a PCOS metabolic/reproductive screening insight to Android and iOS clinical intelligence engines.
- Include BMI, glucose/HbA1c/diabetes status, and PCOS review signs when scoring the screening insight.
- Show clinician-review action steps for cycle changes, excess hair/acne, fertility concerns, and glucose changes.
- Include food/activity guidance relevant to insulin resistance risk using Pakistani meal anchors.
- Warn users not to self-start hormones, metformin, fertility medicines, or supplements from app guidance.
- Keep all copy English-only and non-diagnostic.

## Non-Functional Requirements

- The implementation must be deterministic and unit/smoke-testable.
- The gate must run without backend services, labs, wearables, EHR integration, or AI diagnosis.
- Official source categories must reference NICHD PCOS symptom guidance and CDC PCOS/diabetes risk guidance.
- PCOS support must not add new permissions, analytics, remote upload, or account requirements.

## Acceptance Evidence

- Android unit tests prove PCOS screening reaches high risk for female profile, cycle signs, androgen-sign clues, BMI, and elevated HbA1c.
- iOS smoke tests prove the same screening behavior and self-start medicine warning.
- Android and iOS UI source exposes the new risk factors and PCOS insight through existing clinical panels.
- `bash scripts/validate-pcos-clinical-safety.sh` passes locally and in CI.
- Release evidence includes PCOS clinical safety gate status and documentation checksum.

## Release Boundary

This gate supports education, screening, and clinician follow-up only. It does not diagnose PCOS, prescribe treatment, adjust medications, interpret fertility status, or replace gynecology/endocrinology review.
