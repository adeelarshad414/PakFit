# PakFit Android

PakFit is a spec-first Android MVP for Pakistani health, fitness, workout, and nutrition coaching.

## Current Slice

- Kotlin Android app with Jetpack Compose
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
- Production-readiness audit covering UI/UX, frontend architecture, backend gaps, privacy, security, and clinical governance
- Unit tests driven from the MVP and safety specs
- Offline-friendly Gradle setup for the local Codex workspace

## Run Tests

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
/opt/homebrew/opt/gradle@8/bin/gradle testDebugUnitTest
```

## Build

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export GRADLE_USER_HOME=/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle
/opt/homebrew/opt/gradle@8/bin/gradle assembleDebug
```

On a normal developer machine, you can omit `GRADLE_USER_HOME` or point it at your own Gradle cache.

## Development Rule

Every new feature should start in `specs/`, then become a failing domain test, then move into implementation and UI. This keeps the agent loop measurable and prevents the app from becoming generic fitness advice.

For advanced agentic development, start with `specs/000-master-agentic-development-prompt.md`.
