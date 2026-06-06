# PakFit

PakFit is a spec-first Pakistani health, fitness, workout, and nutrition coaching product with Android and iOS application paths.

## Current Slice

- Kotlin Android app with Jetpack Compose
- SwiftUI iOS app path under `ios/PakFitIOS` with a shared Swift core and tests
- Pakistani recommendation engine for calories, protein, meal guidance, workouts, habits, and safety warnings
- Safety-aware onboarding inputs for age, gender, height, weight, goals, routine, diet, training place, and medical cautions
- Structured medical review warnings for pregnancy, diabetes medication, heart symptoms, kidney disease, eating disorder history, and recent surgery
- Low-impact workout adjustment for knee pain or joint limitation
- Advanced Pakistani lifestyle modes for Ramadan fasting, daawat/wedding weeks, budget groceries, office routines, and eating out
- Equipment-aware workouts for walking routes, no equipment, dumbbells, resistance bands, and gym machines
- Extra plan sections for meal timing, budget grocery list, and plan focus
- BMI screening report and health marker review flags for lipid profile, uric acid, fasting blood sugar, HbA1c, hemoglobin, and diabetes status
- Pakistani food catalog covering desi dishes, roti/rice, daal, protein, sabzi, dairy, desserts, drinks, and snacks
- Manual food entry with category, serving, and calorie details
- In-memory meal logging with daily, weekly, and monthly calorie intake, calorie burn, net calories, and meal counts
- Analysis dashboard with adherence score, health flag count, calorie/burn/protein progress, weekly and monthly summaries
- On-device charts/graphs for recent calorie intake, calories burned, and net calorie trends
- Trend insights, generated todos, and newest-first daily history
- South Asian BMI cutoffs for Pakistani users
- Halal metadata on every default food item and manual food entries
- Blood pressure inputs and emergency escalation flags for chest pain, BP at/above 180/120, and glucose at/above 400 mg/dL
- Prayer-aware workout timing notes, including Ramadan timing guidance
- Phase 2 clinical intelligence MVP with on-device screening insights for diabetes, hypertension, cardiovascular risk, vitamin D risk, and iron/anemia risk
- English-only medical disclaimers, clinical explanations, and crisis guidance
- Light and dark mode selector with adaptive app colors
- Production-style workflow sections for Dashboard, Tracker, Health, Plan, and Setup
- Today overview with intake, burn, net calories, meals, health flags, adherence score, and top screening status
- Holistic daily coach review with score, strengths, and next actions across nutrition, meal timing, activity, hydration, recovery, and health safety
- Daily lifestyle inputs for water, steps, sleep, workout minutes, and stress level
- PHQ-9 and GAD-7 mental wellness screening with severity bands, non-diagnostic copy, and safety actions
- Pakistan crisis and emergency resources surfaced for self-harm thoughts, severe distress, or inability to stay safe
- Daily calorie tracker with meal-level and hourly food entries, hourly intake totals, meal-wise totals, and newest-first food history
- Online calorie search from the Tracker workflow using encoded food queries and Pakistani food context
- Camera capture and food photo preview with portion-based calorie estimate, confidence label, and online verification path
- iOS food photo controls for selecting an image and capturing from camera on iPhone
- Local save/restore/export preview for profile, food logs, health markers, lifestyle inputs, mental wellness inputs, clinical risk factors, and manual foods
- Data-at-rest protection for local snapshots using Android Keystore-backed encryption and iOS Keychain storage
- Android Auto Backup disabled with explicit backup/data-extraction exclusions for sensitive local snapshot storage
- Cross-platform app identity gate for Android application ID/display name and iOS bundle ID/display name
- Android permission privacy gate limiting declared permissions to internet and optional camera for current online search/photo workflows
- Android exported surface gate limiting exported components to the launcher activity
- Android network security gate disabling cleartext traffic and blocking runtime `http://` URL literals
- Cross-platform app icon assets with Android adaptive launcher icons and iOS AppIcon catalog validation
- iOS permission privacy gate keeping camera/photo purpose strings food-photo scoped
- iOS network security gate keeping Swift runtime URLs HTTPS-only and blocking ATS cleartext opt-outs
- Food photo privacy gate proving preview-only capture and blocking image-byte persistence/upload patterns in this local-first build
- Consent and clinical-boundary gate before saving/exporting sensitive local health snapshots
- Android release hardening with R8 minification, resource shrinking, lint gates, and versioned APK/AAB evidence
- Cross-platform version alignment gate for Android source/APK metadata and iOS project metadata
- Checked-in Gradle Wrapper pinned to Gradle 8.14.5 with distribution checksum and wrapper integrity gate
- Strict Gradle dependency verification metadata with SHA-256 checksums for resolved Android artifacts
- Offline dependency inventory with dynamic/SNAPSHOT dependency gate for Android and Swift package posture
- Production-readiness audit covering UI/UX, frontend architecture, backend gaps, privacy, security, and clinical governance
- iOS parity spec and Swift tests for calorie targets, food tracking, BMI, lab markers, online search, and photo estimates
- Unit tests driven from the MVP and safety specs
- Offline-friendly Gradle setup for the local Codex workspace

## Android Tests

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
./gradlew testDebugUnitTest
```

## Android Build

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
./gradlew assembleDebug
```

On a normal developer machine, you can omit `GRADLE_USER_HOME` or point it at your own Gradle cache.

Build local release artifacts:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
./gradlew assembleRelease bundleRelease
```

Production Android release signing is intentionally externalized. Configure all of these environment variables before `assembleRelease` when a real upload keystore is available:

```bash
export PAKFIT_RELEASE_STORE_FILE=/absolute/path/to/upload-keystore.jks
export PAKFIT_RELEASE_STORE_PASSWORD=...
export PAKFIT_RELEASE_KEY_ALIAS=...
export PAKFIT_RELEASE_KEY_PASSWORD=...
```

## iOS Tests

```bash
cd ios/PakFitIOS
swift test
```

If the machine only has Apple Command Line Tools and `XCTest` is unavailable, run:

```bash
cd ios/PakFitIOS
swift run PakFitCoreSmokeTests
```

## iOS App

Open `ios/PakFitIOS/PakFitIOS.xcodeproj` in Xcode, select the `PakFitIOS` target, and run on an iPhone simulator or device.

This Codex machine currently has Command Line Tools selected instead of full Xcode, so simulator builds require installing/selecting Xcode.app first.

## Release Validation

```bash
bash scripts/validate-release.sh
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-android-debug-apk.sh
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-android-release-artifacts.sh
REPORT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit/reports bash scripts/generate-dependency-inventory.sh
REPORT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit/reports bash scripts/generate-release-report.sh
```

GitHub Actions CI is defined in `.github/workflows/pakfit-ci.yml` for Android tests/lint/APK/AAB artifacts, dependency inventory, iOS Swift validation, English-only source checks, and basic secret-pattern checks.

Store/privacy drafts live under `docs/`, and the iOS app includes `PrivacyInfo.xcprivacy` plus an AppIcon asset catalog for current local-only UserDefaults state behavior and branded app packaging. Store identity metadata is documented in `docs/store-metadata.md`.

## Development Rule

Every new feature should start in `specs/`, then become a failing domain test, then move into implementation and UI. This keeps the agent loop measurable and prevents the app from becoming generic fitness advice.

For advanced agentic development, start with `specs/000-master-agentic-development-prompt.md`.
