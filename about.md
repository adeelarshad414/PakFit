# About PakFit

PakFit is a Pakistani health, fitness, workout, and nutrition coaching application for adults. It helps users plan daily meals, track calories, build safe workout routines, review health markers, and understand progress through dashboards and reports.

PakFit is built for local Pakistani routines: roti, rice, daal, sabzi, chai, desserts, drinks, office lunches, family dinners, eating out, Ramadan, budget groceries, home workouts, gym access, and walking-based activity. The app is English-only in the current product direction.

## Purpose

PakFit exists to make everyday health planning practical for Pakistani users who want one place to manage food, movement, calorie balance, and health check-ins.

The app focuses on:

- daily calorie intake, calorie burn, net calories, and meal counts
- Pakistani food logging with default foods and manual food items
- workout planning for home, gym, walking, and equipment-based routines
- BMI and health marker review for common screening values
- progress dashboards with charts, bars, trends, history, and todos
- safety-aware coaching around higher-risk health situations

PakFit provides education, planning, screening, and habit support only. It does not diagnose disease, prescribe treatment, adjust medicines, replace a doctor, replace a dietitian, replace a physiotherapist, or provide emergency care.

## Target Users

PakFit is designed for Pakistani adults who want culturally familiar health and fitness guidance.

Typical users include:

- office workers managing weight, stress, routine, and canteen meals
- home users planning desi meals, snacks, chai, desserts, and family dinners
- gym users tracking calories, protein, workouts, and progress
- users who want to monitor BMI, cholesterol, uric acid, blood sugar, HbA1c, hemoglobin, diabetes status, and blood pressure trends
- users who need cautious planning notes for pregnancy, high blood pressure, kidney disease, diabetes medication, PCOS, anemia risk, vitamin D risk, cardiovascular risk, or mental wellness concerns

## Core Features

### Profile And Plan Setup

Users can set age, gender, height, weight, goal, routine, diet pattern, training place, available equipment, lifestyle modes, and medical cautions. PakFit turns this profile into calorie targets, protein guidance, workout suggestions, meal timing notes, and safety warnings.

### Daily Calorie Tracker

The tracker supports daily, meal-wise, and hourly food logging. Users can record breakfast, lunch, dinner, snacks, chai, drinks, desserts, and custom food entries. PakFit summarizes intake, burn, net calories, meal count, and recent history.

### Pakistani Food Catalog

PakFit includes Pakistani and desi food categories such as roti and rice, daal, protein, sabzi, dairy, snacks, desserts, drinks, and common meals. Users can also add custom categories, food items, serving details, and calories manually.

### Food Search And Photo Estimate

The tracker includes an online calorie search flow using Pakistani food context. Food photo support lets users preview a selected or captured food image, choose a portion, and get a cautious calorie estimate with confidence labeling and manual confirmation guidance.

### Workouts And Lifestyle Coaching

PakFit supports walking, home workouts, no-equipment routines, dumbbells, resistance bands, and gym-machine guidance. It also adapts notes for Ramadan, prayer-aware workout timing, office routines, budget groceries, daawat and wedding weeks, and eating out.

### Health Markers And Reports

Users can review BMI using South Asian cutoffs and enter common health markers including lipid profile, cholesterol context, uric acid, fasting blood sugar, HbA1c, hemoglobin, diabetes status, and blood pressure. PakFit highlights educational review flags and clinician-review boundaries.

### Dashboards And Analysis

PakFit converts records into dashboards with adherence score, progress bars, charts, graphs, calorie trends, burn trends, protein progress, daily records, weekly summaries, monthly summaries, generated todos, and newest-first history.

### Clinical And Mental Wellness Boundaries

PakFit includes cautious, non-diagnostic screening support for diabetes, hypertension, cardiovascular risk, vitamin D risk, iron and anemia risk, PCOS, PHQ-9 style mood screening, GAD-7 style anxiety screening, crisis flags, and Pakistan-aware support resources.

### Safety Modes

The app modifies guidance for higher-risk situations:

- pregnancy pauses weight-loss deficits and keeps nutrition and movement clinician-reviewed
- high blood pressure lowers sodium guidance and keeps movement moderate
- kidney disease caps high-protein targets and avoids supplement-style advice
- diabetes medication pauses aggressive calorie targets and keeps Ramadan timing clinician-reviewed
- PCOS, anemia, vitamin D, cardiovascular, and mental wellness flows stay educational and review-focused

## How To Use PakFit

1. Open the app and complete the setup profile.
2. Choose your goal, routine, diet pattern, training place, and equipment.
3. Add relevant medical cautions and health markers.
4. Review the daily plan, calorie target, meal guidance, workout guidance, and safety notes.
5. Log food by meal or hour throughout the day.
6. Add custom foods, categories, servings, and calories when a food is missing.
7. Enter burn, steps, water, sleep, workout minutes, and stress inputs.
8. Check the dashboard for daily, weekly, and monthly progress.
9. Use trends and todos to decide the next small action.
10. Discuss abnormal symptoms, lab markers, pregnancy, medication timing, glucose concerns, blood pressure concerns, or mental health crisis concerns with a qualified professional.

## Privacy And Data Posture

PakFit is local-first in the current build. Sensitive health snapshots, food logs, profile details, lifestyle inputs, clinical risk factors, consent state, and manual foods are handled on device. Android uses Keystore-backed local snapshot protection, iOS uses Keychain-backed storage, and store privacy documentation is kept aligned with the current local-first behavior.

The current build does not include diagnostic telemetry, health-data analytics SDKs, cleartext runtime URLs, or image upload behavior for food photos.

## Platforms

PakFit has:

- Android app path using Kotlin and Jetpack Compose
- iOS app path using SwiftUI and shared Swift core logic
- release gates for Android tests, lint, APK/AAB artifacts, version alignment, privacy, permissions, screenshots, and iOS handoff evidence

## Production Readiness

PakFit is developed with a specs-first and test-driven workflow. New features start in `specs/`, become tests or validation gates, then move into app implementation and release evidence.

Before public production distribution, PakFit still requires final clinical copy review, signed production Android release signing, App Store and Google Play review preparation, real-device QA, accessibility review on physical devices, and legal/privacy review for the target launch markets.
