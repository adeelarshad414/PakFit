# PakFit Blood Pressure Plan Safety

PakFit now treats high blood pressure as a plan-modifying safety state on Android and iOS.

## Current Behavior

- Users can select High blood pressure in medical cautions.
- The recommendation engine adds a structured blood pressure safety warning.
- Food guidance removes salty-lassi suggestions and adds lower-sodium Pakistani food swaps.
- Ramadan hydration guidance avoids salted lassi and salty electrolyte drinks unless a clinician recommends them.
- Workout guidance switches to moderate conversational movement, relaxed breathing during strength work, warm-ups, cool-downs, and stop-warning symptoms.
- The plan focus includes Blood pressure safety review.

## Source Categories

- AHA getting active to control high blood pressure: https://www.heart.org/en/health-topics/high-blood-pressure/changes-you-can-make-to-manage-high-blood-pressure/getting-active-to-control-high-blood-pressure
- AHA sodium and salt guidance: https://www.heart.org/en/healthy-living/healthy-eating/eat-smart/sodium/sodium-and-salt
- CDC sodium and health context: https://www.cdc.gov/salt/about/index.html
- NHLBI heart-healthy physical activity context: https://www.nhlbi.nih.gov/health/heart-healthy-living/physical-activity

## Copy Boundary

Blood pressure copy must say screening, review, lower-sodium, moderate activity, or clinician follow-up. It must not diagnose hypertension, prescribe or change medicines, promise a BP outcome, present emergency care as optional, or substitute for clinician care.

## Release Boundary

This gate proves source-level blood pressure safety posture. Final production release still needs clinical copy review, device QA, medication-safety review, legal/privacy review, and store age-suitability review before public distribution.
