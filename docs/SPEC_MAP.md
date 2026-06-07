# PakFit Spec Map

## Stack

| Area | Value |
| --- | --- |
| App type | Native Android and native iOS |
| Android | Kotlin, Jetpack Compose, Gradle Wrapper, application ID `com.pakfit.app` |
| iOS | SwiftUI, Swift Package Manager, Xcode project, bundle ID `com.pakfit.ios` |
| Backend | None in this build |
| Database | None in this build |
| Cloud sync | None in this build |
| Runtime ports | None; PakFit does not run a local web server |
| Current version | `0.52.0` build `52` |

## Personas

| Persona | Demo email | Login | Primary workflows |
| --- | --- | --- | --- |
| Office Worker Fat Loss | `office_worker@demo.pakfit.com` | No account login | Fat-loss plan, chai strategy, post-meal walking, calorie tracker, dashboard |
| Beginner Woman Training At Home | `home_beginner@demo.pakfit.com` | No account login | Home workout, privacy-friendly coaching, medical cautions, light/dark mode |
| Vegetarian Student On Budget | `vegetarian_student@demo.pakfit.com` | No account login | Budget groceries, vegetarian proteins, manual foods, local food catalog |
| Gym Muscle Gain User | `gym_user@demo.pakfit.com` | No account login | Gym plan, equipment selection, protein/calorie targets, workout schedule |
| Health Marker Reviewer | `health_reviewer@demo.pakfit.com` | No account login | BMI, lipids, uric acid, glucose, HbA1c, hemoglobin, BP, diabetes status |
| Ramadan Diabetes Medication User | `ramadan_diabetes@demo.pakfit.com` | No account login | Ramadan timing, diabetes medication safety, low-glucose boundary, medical review |

## Screen Inventory

| Screen | Native route ID | Platforms | Description |
| --- | --- | --- | --- |
| Dashboard | `native://dashboard` | Android, iOS | Today overview, calories, burn, net, meals, health flags, adherence, top screening status |
| Tracker | `native://tracker` | Android, iOS | Meal/hour food logging, calorie totals, manual item entry, online search, food-photo estimate |
| Health | `native://health` | Android, iOS | BMI, lab markers, BP, diabetes status, mental wellness, clinical insights, emergency flags |
| Plan | `native://plan` | Android, iOS | Safety warnings, targets, meal guidance, workouts, meal timing, grocery list, plan focus |
| Setup | `native://setup` | Android, iOS | Profile, goal, routine, diet, lifestyle modes, equipment, cautions, theme |

## Feature Inventory

| Feature | Current status |
| --- | --- |
| Pakistani recommendation engine | Implemented and covered by Android/Swift tests |
| Desi food catalog and manual food entry | Implemented |
| Daily/weekly/monthly calorie records | Implemented |
| Analysis dashboard, charts, trends, todos, history | Implemented |
| BMI, lipids, uric acid, glucose, HbA1c, hemoglobin, BP | Implemented as screening/report guidance |
| Safety modes for pregnancy, BP, kidney disease, diabetes medication, PCOS | Implemented with gates |
| Food photo estimate | Local preview and hint-based estimate; no image upload in this build |
| Online calorie search | External Google search URL with Pakistani context |
| Local snapshot storage | Android Keystore-backed and iOS Keychain-backed storage |
| Backend/auth/accounts | Not included in this local-first build |

## Required Environment Variables

| Variable | Required | Purpose |
| --- | --- | --- |
| `JAVA_HOME` | Recommended | JDK 17 for Android builds |
| `ANDROID_HOME` | Recommended | Android SDK command-line tools |
| `ANDROID_SDK_ROOT` | Recommended | Same as `ANDROID_HOME` |
| `GRADLE_USER_HOME` | Optional | Reusable Gradle cache path |
| `PAKFIT_SCREENSHOT_DIR` | Optional | Output directory for generated screenshot previews |
| `PYTHON_CMD` | Optional | Python with Pillow for screenshot generation |
| `PAKFIT_RELEASE_*` | Optional external release only | Android upload-keystore signing inputs |

## Release Evidence

The authoritative release command is `bash scripts/validate-release.sh`. It validates specs, static gates, Android tests/lint/APK/AAB, Swift smoke tests, SwiftUI compile, privacy posture, screenshots, dependency inventory, iOS handoff export, and release evidence reporting.
