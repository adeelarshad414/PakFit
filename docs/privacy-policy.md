# PakFit Privacy Policy Draft

Last updated: 2026-06-05

PakFit is a health, fitness, workout, and nutrition coaching app for Pakistani users. This draft describes the current local-first application behavior in this repository.

## Data The App Handles

PakFit can handle profile details, goals, activity level, diet pattern, training place, lifestyle modes, equipment access, medical cautions, food logs, custom food items, calorie records, lifestyle inputs, lab marker values, BMI screening, mental wellness screener inputs, clinical risk factors, consent state, and food photo hints.

## Local Storage

The current app stores sensitive data only on the user's device after required consent acknowledgements are complete. Local snapshots can include profile, health markers, food logs, lifestyle inputs, mental wellness inputs, clinical risk factors, consent state, and manual food items.

Saved local snapshots are protected at rest with platform storage controls: Android uses an Android Keystore-backed encrypted payload, and iOS stores the sensitive snapshot payload in Keychain. Android Auto Backup is disabled for the app, and Android backup/data-extraction rules explicitly exclude the sensitive local snapshot preference.

Food photo image bytes are not saved in the local snapshot, written to app files, or uploaded by app code in this build.

## Network Use

The current app has no account backend, no cloud sync, no remote analytics, and no remote health data upload. Online calorie search opens a user-controlled web search query for food calorie verification.

## Camera And Photos

Camera/photo features are used for user-selected food photo workflows. Current calorie estimates are based on user food hints, selected portion, and the PakFit catalog. The app does not claim diagnostic image recognition or a reviewed vision model in this slice.

## Health And Clinical Boundaries

PakFit provides education, planning, screening, and habit support. It does not diagnose, treat disease, prescribe therapy, replace a doctor, replace a dietitian, replace a physiotherapist, or provide emergency mental health care.

If symptoms are severe or safety is at risk, users should contact local emergency services or a qualified healthcare professional.

## Analytics

Analytics are off in the current app. Future analytics require a separate schema, privacy notice, and explicit opt-in before implementation.

## User Controls

Users can save, restore, export-preview, and clear the local snapshot from the app's local data/privacy controls. Export preview is user-controlled plaintext and should be handled carefully.

## Production Release Notes

Before public store release, this policy must be reviewed by qualified legal/privacy counsel, hosted at a stable public URL, and kept consistent with Google Play Data safety and App Store privacy disclosures.
