# Test Strategy

## Test Pyramid

- Domain unit tests for recommendation behavior and safety warnings.
- Future ViewModel tests for state behavior.
- Future Compose UI tests for onboarding and plan review.
- Future repository tests for persistence.
- CI checks for tests, Android lint, build, dependency inventory, release artifact evidence, and source/security gates.
- Future online vulnerability scanning and deeper UI automation.

## Current Required Tests

- Safe user receives a plan and no warnings.
- Pregnancy creates medical review warning.
- Pregnancy removes ordinary fat-loss calorie deficit behavior and switches to clinician-reviewed gentle movement.
- High blood pressure modifies sodium, Ramadan hydration, and moderate movement guidance.
- Diabetes medication creates medical review warning.
- Heart symptoms create medical review warning.
- Kidney disease creates medical review warning.
- Eating disorder history creates medical review warning.
- Recent surgery creates medical review warning.
- Knee pain modifies workout away from high-impact sessions.
- Ramadan mode adds suhoor, iftar, hydration, and after-iftar training guidance.
- Ramadan plus diabetes medication creates a fasting-specific warning.
- Daawat mode avoids shame-based words.
- Budget vegetarian mode adds affordable local grocery suggestions.
- Office routine mode adds chai, walking, and sitting-break habit anchors.
- Eating-out mode adds local restaurant/canteen choices.
- Equipment selection changes workout content.
- BMI value and category are calculated.
- Lipid, uric acid, blood sugar, HbA1c, hemoglobin, and diabetes markers create review flags.
- Pakistani food catalog includes major desi food groups, desserts, drinks, and dishes.
- Manual food items can be added and logged.
- Daily, weekly, and monthly calorie summaries calculate intake, burn, net calories, and meal count.
- Dashboard metrics calculate target progress, health flag count, and todo count.
- Chart points are generated for intake, burn, and net calorie history.
- Trends detect improving, steady, and needs-attention cases.
- Todos are generated from low meal count, low burn, health flags, and low protein progress.
- History is sorted newest first and exposes recent records.
- Existing Pakistani food, vegetarian, home workout, and goal behavior tests remain passing.
- Android lintDebug and lintRelease pass before APK/AAB artifacts are accepted.
- Cross-platform version alignment gate passes before APK/AAB artifacts are accepted.
- App identity metadata gate passes before APK/AAB artifacts and iOS release evidence are accepted.
- App icon asset gate passes before APK/AAB artifacts and iOS release evidence are accepted.
- Platform compatibility gate passes before APK/AAB artifacts and iOS release evidence are accepted.
- Android build toolchain gate passes before APK/AAB artifacts are accepted.
- Gradle Wrapper integrity gate passes before APK/AAB artifacts are accepted.
- Strict Gradle dependency verification passes before APK/AAB artifacts are accepted.
- Android permission privacy gate passes before APK/AAB artifacts are accepted.
- Android exported component surface gate passes before APK/AAB artifacts are accepted.
- Android network security gate passes before APK/AAB artifacts are accepted.
- iOS permission privacy gate passes before APK/AAB artifacts and iOS release evidence are accepted.
- iOS network security gate passes before APK/AAB artifacts and iOS release evidence are accepted.
- Food photo privacy gate passes before APK/AAB artifacts are accepted.
- Release builds keep R8 minification and resource shrinking enabled.
- Dynamic and SNAPSHOT dependency declarations fail the dependency inventory gate.

## Acceptance Criteria

### Scenario: TDD gate

Given a new health behavior is requested  
When code is changed  
Then a spec and domain test are added or updated first
