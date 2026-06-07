# Spec 065: Kidney Plan Safety Gate

## Goal

Add plan-modifying kidney disease support for Pakistani users while keeping diagnosis, renal nutrition prescriptions, dialysis-stage guidance, medicine/supplement decisions, and clinician replacement outside the app.

## Functional Requirements

- Keep Kidney disease as an Android and iOS medical caution.
- Keep a structured medical review warning with renal dietitian guidance.
- Cap high-protein targets when kidney disease is selected.
- Remove muscle-gain workout labels when kidney disease is selected.
- Add kidney-specific food guidance that covers protein, sodium, potassium, phosphorus, fluids, kidney stage, dialysis status, medicines, and labs.
- Block self-started high-protein diets, creatine, herbal kidney cures, detox drinks, or supplement stacks from app guidance.
- Add Kidney safety review to plan focus.
- Keep pregnancy behavior higher priority for movement when pregnancy is selected, while kidney safety still caps protein and adds kidney guidance.

## Non-Functional Requirements

- Android and iOS behavior must remain source-level aligned.
- Official source categories must reference NIDDK CKD eating guidance, NIDDK kidney failure nutrition guidance, CDC CKD self-care guidance, and National Kidney Foundation CKD nutrition context.
- The gate must not add new permissions, analytics, remote upload, accounts, or backend requirements.
- Public copy must avoid diagnosis, prescription, supplement recommendation, guaranteed kidney outcome, universal dialysis-stage advice, and clinician-replacement claims.

## Test Requirements

- Android unit tests prove kidney disease caution caps high-protein muscle-gain targets, uses renal clinician-reviewed movement labeling, avoids muscle-gain workout title claims, includes renal dietitian copy, includes potassium/phosphorus review, and blocks self-started high-protein behavior.
- iOS smoke and XCTest coverage prove the same plan behavior.
- Static validation proves Android/iOS source, docs, store copy, CI, release report, and release validation all include the kidney plan safety gate.

## Boundary

This gate supports education, planning, and clinician follow-up only. It does not diagnose kidney disease, prescribe protein/sodium/potassium/phosphorus/fluid limits, interpret dialysis status, recommend supplements, claim kidney-function improvement, or replace clinician care.
