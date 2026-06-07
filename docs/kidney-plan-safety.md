# PakFit Kidney Plan Safety

PakFit now uses the Kidney disease caution as a plan-modifying safety state on Android and iOS.

## Current Behavior

- Users can select Kidney disease in medical cautions.
- The recommendation engine keeps a structured medical review warning.
- High-protein fat-loss or muscle-gain targets are capped to a conservative renal-review number.
- Muscle-gain workout labels are replaced with Kidney clinician-reviewed Movement Plan.
- Nutrition guidance tells users that protein is a renal-dietitian review number, not a prescription.
- Food guidance asks users to review protein, sodium, potassium, phosphorus, fluids, kidney stage, dialysis status, medicines, and labs with a clinician or renal dietitian.
- The plan blocks self-starting high-protein diets, creatine, unreviewed herbal kidney products, detox drinks, and supplement stacks from app guidance.

## Source Categories

- NIDDK healthy eating for adults with CKD: https://www.niddk.nih.gov/health-information/kidney-disease/chronic-kidney-disease-ckd/eating-nutrition
- NIDDK eating right with kidney failure: https://www.niddk.nih.gov/health-information/kidney-disease/kidney-failure/eating-right
- CDC living with chronic kidney disease: https://www.cdc.gov/kidney-disease/living-with/index.html
- National Kidney Foundation nutrition and kidney disease stages 1-5: https://www.kidney.org/kidney-topics/nutrition-and-kidney-disease-stages-1-5-not-dialysis

## Copy Boundary

Kidney copy must say review, renal dietitian, kidney clinician, lab-dependent, stage-dependent, dialysis-dependent, or medical follow-up. It must not diagnose kidney disease, prescribe protein, prescribe sodium/potassium/phosphorus/fluid limits, recommend supplements, claim to improve kidney function, present dialysis-stage guidance as universal, or substitute for clinician care.

## Release Boundary

This gate proves source-level kidney safety posture. Final production release still needs nephrology/renal dietitian copy review, device QA, medication/supplement boundary review, legal/privacy review, and store age-suitability review before public distribution.
