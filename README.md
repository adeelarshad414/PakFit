# PakFit

PakFit is a spec-first Pakistani health, fitness, workout, and nutrition coaching product with Android and iOS application paths.

See [`about.md`](about.md) for a customer-friendly overview of the application purpose, features, usage, privacy posture, and production readiness.

## Current Slice

- Kotlin Android app with Jetpack Compose
- SwiftUI iOS app path under `ios/PakFitIOS` with a shared Swift core and tests
- Pakistani recommendation engine for calories, protein, meal guidance, workouts, habits, and safety warnings
- Safety-aware onboarding inputs for age, gender, height, weight, goals, routine, diet, training place, and medical cautions
- Structured medical review warnings for pregnancy, diabetes medication, heart symptoms, kidney disease, eating disorder history, and recent surgery
- Pregnancy safety mode that pauses weight-loss calorie deficits and switches to clinician-reviewed nutrition and gentle movement guidance
- Blood pressure safety mode that lowers sodium guidance and switches to moderate clinician-review movement guidance
- Kidney safety mode that caps high-protein targets and switches to renal clinician-review nutrition and movement guidance
- Diabetes medication safety mode that pauses aggressive calorie targets and switches to clinician-reviewed meal timing and moderate movement guidance
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
- Adult-use safety boundary for Pakistani adults 18 and older, including under-18 warning behavior for restored or programmatic profiles
- Phase 2 clinical intelligence MVP with on-device screening insights for diabetes, hypertension, cardiovascular risk, vitamin D risk, iron/anemia risk, and PCOS metabolic/reproductive screening
- English-only medical disclaimers, clinical explanations, and crisis guidance
- Light and dark mode selector with adaptive app colors
- Production-style workflow sections for Dashboard, Tracker, Health, Plan, and Setup
- iOS Setup tab for editing theme, adult-safe profile values, goals, routine, diet pattern, lifestyle modes, and medical cautions
- iOS Health marker inputs for diabetes status, lipid profile, uric acid, fasting blood sugar, blood pressure, HbA1c, hemoglobin, and severe symptom escalation
- iOS Dashboard inputs for calories burned, water, steps, sleep, workout minutes, stress, and dynamic daily coach review
- iOS Analysis Dashboard for adherence score, progress bars, charts, graphs, trends, todos, weekly/monthly summaries, and history
- iOS Health clinical and mental wellness controls for risk factors, PHQ-9, GAD-7, crisis flags, clinical insights, and Pakistan support resources
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
- Platform compatibility gate with Android compile/target SDK 35 and iOS deployment/Swift settings evidence
- Android build toolchain gate with AGP 8.6.x support for compileSdk 35
- Android release signing hygiene gate keeping upload keystores and signing passwords outside source control
- Store listing and release notes gate for app identity, current version, privacy boundaries, English-only copy, and unsafe medical-claim scanning
- Store screenshot asset gate for generated English-only workflow previews, PNG dimensions, contact sheet, and nonblank output
- Cross-platform app icon assets with Android adaptive launcher icons and iOS AppIcon catalog validation
- iOS permission privacy gate keeping camera/photo purpose strings food-photo scoped
- iOS network security gate keeping Swift runtime URLs HTTPS-only and blocking ATS cleartext opt-outs
- iOS signing hygiene gate keeping Apple certificates, provisioning profiles, export options, and App Store credentials outside source control
- iOS application handoff artifact with versioned Xcode project, SwiftUI source, Swift core, tests, AppIcon assets, manifest, and checksums
- Agentic developer pipeline with native start/stop scripts, VS Code tasks, SPEC_MAP, quick commands, setup guide, screenshots, and demo video script
- Food photo privacy gate proving preview-only capture and blocking image-byte persistence/upload patterns in this local-first build
- Store privacy disclosure consistency gate aligning Android permissions, iOS privacy manifest, privacy policy, Google Play Data safety, App Store privacy, and store listing claims
- Consent and clinical-boundary gate before saving/exporting sensitive local health snapshots
- Accessibility and readability gate for Android/iOS semantic headings, custom chart/progress labels, food-photo descriptions, iOS Dynamic Type-friendly fonts, and screen-reader documentation
- Diagnostic privacy gate blocking runtime health-data logging, crash/analytics/telemetry SDK patterns, and mismatched privacy disclosures
- Adult-use safety gate for age floor, under-18 warnings, iOS safety warning display, and adult audience listing copy
- iOS setup parity gate for editable profile/setup controls connected to shared iOS recommendation and snapshot state
- iOS health marker parity gate for editable clinical marker controls connected to shared iOS health reports and snapshot state
- iOS lifestyle coach parity gate for editable daily inputs and dynamic coach review connected to shared iOS snapshot state
- iOS clinical and mental wellness parity gate for editable risk factors, screeners, crisis resources, and clinical insight reports
- PCOS clinical safety gate for non-diagnostic metabolic/reproductive screening, clinician-review actions, and medication/self-treatment boundaries
- Pregnancy plan safety gate for clinician-reviewed nutrition, gentle movement, and no weight-loss deficit behavior on Android and iOS
- Blood pressure plan safety gate for lower-sodium guidance, moderated movement, and BP medicine self-adjustment boundaries on Android and iOS
- Kidney plan safety gate for capped high-protein targets, renal clinician-review guidance, and high-protein/supplement self-treatment boundaries on Android and iOS
- Diabetes medication plan safety gate for paused aggressive calorie targets, clinician-reviewed Ramadan timing, moderated movement, and medicine self-adjustment boundaries on Android and iOS
- iOS analysis dashboard parity gate for local summaries, charts, trends, todos, and history reporting
- Android release hardening with R8 minification, resource shrinking, lint gates, and versioned APK/AAB evidence
- iOS app handoff artifact gate for local review evidence while signed IPA/App Store archive creation remains external
- Agentic development pipeline gate for start/stop scripts, VS Code tasks, SPEC_MAP, quickref, setup guide, screenshots, and demo script artifacts
- Cross-platform version alignment gate for Android source/APK metadata and iOS project metadata
- Checked-in Gradle Wrapper pinned to Gradle 8.14.5 with distribution checksum and wrapper integrity gate
- Strict Gradle dependency verification metadata with SHA-256 checksums for resolved Android artifacts
- Offline dependency inventory with dynamic/SNAPSHOT dependency gate for Android and Swift package posture
- Dependency advisory monitoring gate with Dependabot coverage for Gradle, Swift Package Manager, and GitHub Actions
- Security governance gate with SECURITY.md, CODEOWNERS coverage, vulnerability-reporting boundaries, and read-only CI permissions
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

Export the local iOS application handoff artifact:

```bash
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-ios-app-handoff.sh
```

The handoff archive is source/project review evidence, not a signed IPA or simulator `.app`.

## Release Validation

```bash
bash scripts/validate-release.sh
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-android-debug-apk.sh
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-android-release-artifacts.sh
OUTPUT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit bash scripts/export-ios-app-handoff.sh
REPORT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit/reports bash scripts/generate-dependency-inventory.sh
REPORT_DIR=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit/reports bash scripts/generate-release-report.sh
```

GitHub Actions CI is defined in `.github/workflows/pakfit-ci.yml` for Android tests/lint/APK/AAB artifacts, iOS application handoff artifacts, dependency inventory, iOS Swift validation, English-only source checks, and basic secret-pattern checks.

Store/privacy drafts live under `docs/`, and the iOS app includes `PrivacyInfo.xcprivacy` plus an AppIcon asset catalog for current local-only UserDefaults state behavior and branded app packaging. Store identity metadata is documented in `docs/store-metadata.md`, store listing copy is drafted in `docs/store-listing.md`, versioned release notes live under `docs/release-notes/`, release signing posture is documented in `docs/release-signing.md`, dependency advisory monitoring is documented in `docs/dependency-advisory-monitoring.md`, security governance is documented in `SECURITY.md` and `docs/security-governance.md`, accessibility readiness is documented in `docs/accessibility-readability.md`, diagnostic privacy is documented in `docs/diagnostics-privacy.md`, adult-use safety is documented in `docs/adult-use-safety.md`, iOS setup parity is documented in `docs/ios-setup-parity.md`, iOS health marker parity is documented in `docs/ios-health-marker-parity.md`, iOS lifestyle coach parity is documented in `docs/ios-lifestyle-coach-parity.md`, iOS clinical and mental wellness parity is documented in `docs/ios-clinical-mental-parity.md`, PCOS clinical safety is documented in `docs/pcos-clinical-safety.md`, pregnancy plan safety is documented in `docs/pregnancy-plan-safety.md`, blood pressure plan safety is documented in `docs/blood-pressure-plan-safety.md`, kidney plan safety is documented in `docs/kidney-plan-safety.md`, iOS analysis dashboard parity is documented in `docs/ios-analysis-dashboard-parity.md`, iOS application handoff evidence is documented in `docs/ios-app-handoff-artifact.md`, and platform SDK posture is documented in `docs/platform-compatibility.md`.

Store screenshot previews can be rendered and validated with `bash scripts/validate-store-screenshots.sh`. Set `PAKFIT_SCREENSHOT_DIR=/absolute/output/path` to write them outside the ignored repo output folder.

## Development Rule

Every new feature should start in `specs/`, then become a failing domain test, then move into implementation and UI. This keeps the agent loop measurable and prevents the app from becoming generic fitness advice.

For advanced agentic development, start with `specs/000-master-agentic-development-prompt.md`.
