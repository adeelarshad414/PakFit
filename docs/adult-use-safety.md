# PakFit Adult-Use Safety Boundary

PakFit is designed for Pakistani adults 18 and older. The app handles calorie targets, workout planning, BMI screening, food logs, lab markers, diabetes-related context, and mental wellness screeners that can be inappropriate for children or adolescents without professional oversight.

## Current Safeguards

- Android setup uses an adult age floor of 18 for new profile entry.
- Android slider rendering clamps out-of-range saved values so older local snapshots cannot break the setup screen.
- Android and iOS recommendation engines add an adult-use safety warning when a restored, imported, or programmatic profile has age under 18.
- The adult-use warning asks people under 18 to use nutrition, calorie, and training guidance only with a parent or guardian and a qualified clinician or coach.
- iOS Plan shows safety warnings from the shared recommendation engine.

## Product Rule

Do not present PakFit as a pediatric nutrition, weight-loss, diabetes, or workout app. Future youth-specific support requires a separate pediatric safety spec, qualified clinical review, guardian consent design, store rating review, privacy review, and age-appropriate UX.

## Release Boundary

This gate proves source-level adult-use posture. Public release still requires store rating questionnaire review, legal/privacy review, and final listing copy review for age suitability.
