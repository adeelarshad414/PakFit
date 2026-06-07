# Spec 064: Blood Pressure Plan Safety Gate

## Goal

Add plan-modifying high blood pressure support for Pakistani users while keeping diagnosis, medicine changes, emergency decisions, and clinician replacement outside the app.

## Functional Requirements

- Add High blood pressure as an Android and iOS medical caution.
- Add a structured safety warning that uses plan modification and clinician-review language.
- Replace generic salty-lassi hydration guidance with lower-sodium guidance when the caution is selected.
- Add Pakistani lower-sodium food guidance covering achar, papad, packaged nimco, salty chutneys, restaurant karahi, and salty raita.
- Switch workouts to moderate conversational movement, relaxed breathing during strength work, warm-ups, cool-downs, and stop-warning symptoms.
- Add Blood pressure safety review to plan focus.
- Keep pregnancy behavior higher priority when pregnancy is selected.

## Non-Functional Requirements

- Android and iOS behavior must remain source-level aligned.
- Official source categories must reference AHA high blood pressure physical activity guidance, AHA sodium/salt guidance, CDC sodium context, and NHLBI heart-healthy physical activity context.
- The gate must not add new permissions, analytics, remote upload, accounts, or backend requirements.
- Public copy must avoid diagnosis, medication adjustment, guaranteed BP outcome, and clinician-replacement claims.

## Test Requirements

- Android unit tests prove high blood pressure caution modifies the plan, labels the workout, avoids salted lassi in Ramadan guidance, keeps conversational intensity, and blocks BP medicine self-adjustment.
- iOS smoke and XCTest coverage prove the same plan behavior.
- Static validation proves Android/iOS source, docs, store copy, CI, release report, and release validation all include the blood pressure safety gate.

## Boundary

This gate supports education, planning, and clinician follow-up only. It does not diagnose hypertension, prescribe or adjust medicine, decide emergency care, guarantee blood pressure improvement, or replace clinician care.
