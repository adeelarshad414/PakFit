# PakFit iOS Health Marker Parity

The iOS Health marker workflow now lets Pakistani users edit the health marker inputs that drive BMI and screening flags instead of only reading default values.

The editable marker set covers lipid profile, uric acid, fasting blood sugar, HbA1c, hemoglobin, blood pressure, diabetes status, and severe symptom escalation.

## Current iOS Health Marker Inputs

- Diabetes status.
- Lipid profile: total cholesterol, LDL, HDL, and triglycerides.
- Uric acid.
- Fasting blood sugar.
- Blood pressure: systolic BP and diastolic BP.
- HbA1c.
- Hemoglobin.
- Chest pain or severe symptom escalation flag.

## Product Rule

Health marker edits must update the shared `PakFitViewModel.labProfile` immediately so health flags, emergency escalation, local snapshot save/restore/export, and store privacy disclosures all reflect the same current values.

## Clinical Boundary

The app shows screening information only. Abnormal cholesterol, uric acid, fasting blood sugar, HbA1c, hemoglobin, diabetes status, blood pressure, or severe symptom values should be reviewed with a qualified clinician.

## Release Boundary

This static gate proves source-level iOS marker parity. Final production release still needs iPhone device QA, VoiceOver, large-text review, and clinical copy review.
