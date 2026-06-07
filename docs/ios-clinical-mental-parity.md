# PakFit iOS Clinical And Mental Wellness Parity

The iOS Health workflow now exposes clinical risk insights and mental wellness screening controls for Pakistani users instead of only storing those values for snapshots.

The workflow covers PHQ-9, GAD-7, crisis support, diabetes risk, BP risk, heart risk, vitamin D risk, and anemia risk.

## Current iOS Clinical Inputs And Insights

- Clinical risk factors for family history diabetes, family history high BP, early heart disease, high-salt routine, low sun exposure, low-iron diet, heavy periods or blood loss, and smoking or tobacco.
- Clinical risk insights for diabetes risk, BP risk, heart risk, vitamin D risk, and anemia risk.
- Non-diagnostic risk levels, action steps, and source categories.

## Current iOS Mental Wellness Inputs

- PHQ-9 score.
- GAD-7 score.
- Crisis support flags for self-harm thoughts, panic or severe distress, and inability to stay safe.
- Crisis escalation copy and Pakistan support resources when a crisis flag is selected.

## Product Rule

Clinical and mental wellness edits must update `PakFitViewModel.clinicalRiskFactors`, `PakFitViewModel.mentalWellnessInput`, visible reports, and secure local snapshots in the same session. All copy remains English-only, local-first, and non-diagnostic.

## Release Boundary

This static gate proves source-level iOS clinical and mental wellness parity. Final production release still needs iPhone device QA, VoiceOver, large-text review, clinical copy review, mental health safety review, and store age-suitability review.
