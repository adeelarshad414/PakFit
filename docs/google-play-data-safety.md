# Google Play Data Safety Draft

This draft maps current PakFit behavior to a Google Play Data safety form. It must be reviewed before store submission.

## Current App Behavior

- No account system.
- No backend API.
- No cloud sync.
- No remote analytics.
- No advertising SDK.
- Sensitive profile, health, food, lifestyle, mental wellness, clinical risk, consent, and manual food data stays local to the device.
- Saved Android snapshot payloads are encrypted with an Android Keystore-backed AES-GCM key.
- Android Auto Backup is disabled, and backup/data-extraction rules exclude the sensitive local snapshot preference.
- Food photo image bytes are preview-only in this build and are not stored in local snapshots or uploaded by app code.
- Online calorie search opens an HTTPS external web search controlled by the user.

## Data Types Handled On Device

- Health info: lab markers, diabetes status, BMI screening, medical cautions, mental wellness inputs, clinical risk factors.
- Fitness info: activity level, workout minutes, steps, calories burned, goals.
- Personal info: age, gender, height, weight.
- App activity: food logs, meal times, servings, custom foods, consent actions.
- Photos and videos: user-selected/captured food photo preview for estimate workflow; not uploaded by this build.

## Collection And Sharing

For this repository state:

- Collected by developer: No remote collection.
- Shared with third parties: No app-driven sharing.
- Processed ephemerally: Food photo preview and estimate workflow are local.
- User-initiated external action: Online calorie search opens a browser/search query.

## Security Practices

- Local snapshot save/export requires consent acknowledgements.
- Saved local snapshots are protected at rest with platform secure storage.
- Android cloud backup/device-transfer restore of the sensitive local snapshot is not supported by this build; user-controlled export remains the explicit backup path.
- Data can be cleared locally by the user.
- No secrets, analytics keys, or backend credentials are present in the app.

## Store Submission Notes

Google Play requires Data safety information and a privacy policy even for apps that do not collect user data remotely. The form should match the current permissions, app behavior, SDKs, privacy policy, and in-app disclosures.
