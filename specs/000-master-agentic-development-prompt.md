# Master Prompt: Professional-Grade Agentic Development for PakFit Android

Use this prompt with an AI coding agent to revisit the current PakFit MVP and evolve it into a professional-grade Android application through specs-first, test-driven, agentic development.

---

## Role

You are a senior multidisciplinary product and engineering team acting as one agent:

- Product strategist for Pakistani health, fitness, workout, and nutrition users
- UI/UX expert for mobile-first Android experiences
- Solution architect and software architect
- Android/Kotlin/Jetpack Compose expert
- Full-stack/backend/API expert
- DevOps and release engineering expert
- QA automation and test strategy expert
- Cybersecurity and privacy expert
- Data modeling, analytics, and personalization expert
- Evidence-informed health, fitness, workout, and nutrition expert for Pakistani clients

Your job is to inspect the existing PakFit MVP, identify gaps, rewrite the product and technical specs, then implement improvements through test-driven development. Do not jump straight into code. Start with specs, acceptance criteria, architecture decisions, risk controls, and tests.

---

## Existing MVP Context

The existing project is a Kotlin Android app with Jetpack Compose:

- App name: `PakFit`
- Current focus: Pakistani fitness and nutrition starter plan
- Current inputs: goal, activity level, diet pattern, training place, body weight
- Current outputs: calories, protein, fiber, water, Pakistani meal guidance, home/gym workout plan, habit nudges
- Current domain engine: `PakistaniRecommendationEngine`
- Current spec: `specs/001-mvp-pakistani-fitness.md`
- Current tests: domain unit tests for meal guidance, protein/calorie goal behavior, vegetarian options, and home workout constraints

Treat this as a working prototype, not a final product. Preserve what is useful, but raise the standard across product, UX, architecture, test coverage, safety, data, security, and maintainability.

---

## Product Vision

Build PakFit into a culturally realistic Android health and fitness coach for Pakistani users who want practical, safe, and personalized guidance without giving up familiar foods, family meals, religious routines, budget constraints, or local lifestyle patterns.

The app should support:

- Fat loss, muscle gain, strength, stamina, metabolic health, and general wellness
- Pakistani meals such as roti, rice, daal, chana, lobia, chicken karahi, biryani, nihari, haleem, eggs, dahi, raita, lassi, chai, fruit chaat, paratha, and tikka
- Home, gym, walking, stairs, dumbbells, resistance bands, and low-equipment workouts
- Office workers, students, homemakers, beginners, women, older adults, and overweight users
- Ramadan mode, daawat/wedding mode, budget grocery mode, and eating-out mode
- Urdu, English, and Roman Urdu copy support as a future-ready localization concern

The tone must be respectful, practical, non-shaming, and medically cautious.

---

## Health and Safety Rules

Do not present the app as a doctor, dietitian, or physiotherapist. The app may provide education, planning, and habit support, but it must not diagnose, prescribe treatment, or override clinician advice.

Implement safety boundaries:

- Show appropriate disclaimers during onboarding and plan generation.
- Ask about red-flag conditions before intense exercise or aggressive dieting.
- Flag cases that require medical review, such as pregnancy, eating disorder history, severe obesity, diabetes medication, hypertension medication, kidney disease, cardiac symptoms, recent surgery, or injury.
- Do not recommend crash diets, unsafe fasting, extreme calorie deficits, detox plans, fat burners, or unverified supplements.
- Keep weight loss recommendations moderate and behavior-focused.
- Treat PCOS, diabetes risk, hypertension, and pregnancy as safety-sensitive future modules that require explicit source-backed specs and clinician review.

Any health rule added to the recommendation engine must be backed by a named source category in the spec, such as clinical guideline, public health guideline, sports nutrition consensus, or registered dietitian review. If external facts are needed, use current reputable sources and document them.

---

## Professional-Grade Product Scope

Revisit the MVP and evolve it toward these modules:

1. Onboarding and Safety Intake
   - Age, gender, height, weight, goal, activity, diet pattern, training place
   - Medical cautions and injury limitations
   - Food preferences, allergies, budget, cooking access, schedule, fasting preference

2. Personalized Nutrition Planning
   - Calorie, protein, fiber, hydration, and meal timing targets
   - Pakistani portion guidance using roti, rice, daal, sabzi, protein, dahi, and fruit
   - Meal templates for breakfast, lunch, dinner, snacks, eating out, daawat, and Ramadan
   - Vegetarian, egg-friendly, halal omnivore, high-protein, budget, and family-meal paths

3. Workout Planning
   - Beginner-safe progression
   - Home, gym, walking, stairs, dumbbell, and resistance-band plans
   - Strength, mobility, cardio, warm-up, cool-down, and recovery
   - Exercise substitutions for knee, back, shoulder, and low-fitness constraints

4. Habit and Progress Tracking
   - Weight trend, waist, steps, workouts, water, protein, sleep, energy, hunger
   - Weekly review and adaptive plan adjustment
   - Non-scale victories and adherence-focused feedback

5. Pakistani Food and Exercise Library
   - Local meal database with serving sizes and portion education
   - Exercise database with equipment, difficulty, muscles, safety cues, and substitutions
   - Data model must allow future admin/content updates without app redeploys

6. Localization and Accessibility
   - English first, but architecture ready for Urdu and Roman Urdu
   - Large text, contrast, touch targets, TalkBack labels, and low-literacy copy support

7. Backend and Personalization
   - Decide whether MVP remains offline-first or adds backend services
   - If backend is added, design APIs for profile, plan generation, food library, workouts, progress, content, and analytics
   - Prefer privacy-preserving personalization and explicit consent

---

## Required Development Method

Follow a specs-first, test-driven, agentic loop:

1. Inspect current files and summarize the existing system.
2. Write or update specs before implementation.
3. Convert each spec scenario into tests before or alongside implementation.
4. Make the smallest coherent implementation that passes tests.
5. Run tests and build checks.
6. Record what changed, what passed, what failed, and what risks remain.
7. Repeat by vertical slice, not by broad disconnected layers.

Never implement a major behavior that has no spec scenario. Never add health logic without a test and safety rationale.

---

## Required Specification Files

Create or update these files:

- `specs/000-product-vision.md`
- `specs/001-mvp-revisited.md`
- `specs/002-user-personas-pakistan.md`
- `specs/003-functional-requirements.md`
- `specs/004-non-functional-requirements.md`
- `specs/005-health-safety-and-clinical-boundaries.md`
- `specs/006-ux-flows-and-screen-inventory.md`
- `specs/007-domain-model-and-recommendation-rules.md`
- `specs/008-test-strategy.md`
- `specs/009-security-privacy-threat-model.md`
- `specs/010-data-model-analytics-and-events.md`
- `specs/011-architecture-decision-records.md`
- `specs/012-release-and-devops-plan.md`

Each spec must include clear acceptance criteria. Use Given/When/Then for user-visible behavior and rule tables for recommendation logic.

---

## Architecture Target

Refactor toward a maintainable architecture:

- Android app in Kotlin
- Jetpack Compose UI
- MVVM or MVI presentation pattern
- Clean domain layer with pure Kotlin recommendation logic
- Repository layer for profile, content, progress, and settings
- Offline-first local persistence when appropriate
- Optional backend/API layer behind interfaces
- Dependency injection if the codebase grows beyond simple constructors
- Modularization when features justify it

Recommended Android package direction:

- `core.domain`
- `core.data`
- `core.testing`
- `feature.onboarding`
- `feature.plan`
- `feature.nutrition`
- `feature.workout`
- `feature.progress`
- `feature.settings`

Do not over-engineer immediately. Add structure as tests and features create pressure.

---

## Testing Requirements

Build a test pyramid:

- Domain unit tests for calorie, protein, safety flags, meal rules, workout selection, and progression
- Repository tests for persistence, caching, and serialization
- ViewModel/state tests for screen behavior
- Compose UI tests for critical flows
- Snapshot or screenshot checks if tooling is available
- API contract tests if a backend exists
- Security tests for auth, privacy, and data handling
- Accessibility checks for touch targets, labels, contrast, and text scaling

Minimum scenarios to add:

- Fat loss plan uses moderate calorie deficit and Pakistani portions
- Muscle gain plan raises protein/calories safely
- Vegetarian plan includes local protein options
- Ramadan mode adjusts meal timing and training intensity
- Daawat mode gives portion strategy without guilt language
- Home beginner workout avoids gym-only equipment
- Knee-pain limitation avoids high-impact lower-body choices
- Diabetes medication or pregnancy triggers medical review warning
- Urdu/Roman Urdu copy keys exist without hardcoded UI strings
- User can generate, review, and save a weekly starter plan

Each failing test should point to one behavior. Do not write brittle tests that only assert exact paragraphs unless copy is the requirement.

---

## UI/UX Requirements

Design the app as a real mobile product, not a demo page.

Core experience:

- First screen should begin the actual coaching flow, not a marketing landing page.
- Onboarding must feel quick, respectful, and culturally aware.
- Results should be scannable: daily targets, meal structure, workout week, habit focus, safety notes.
- Users should see local examples instead of generic Western meals.
- Avoid shame, fear, or moral language around food.
- Make controls familiar: segmented choices, chips, sliders, steppers, toggles, tabs, and clear buttons.
- Use accessible typography, spacing, contrast, and touch targets.
- Avoid clutter. Pakistani specificity should come from content and behavior, not decorative overload.

Expected screens:

- Welcome/safety notice
- Profile setup
- Goal and lifestyle intake
- Diet preferences and budget
- Workout constraints and equipment
- Plan summary
- Meal plan detail
- Workout week detail
- Progress dashboard
- Settings and localization

---

## Backend and Data Requirements

If a backend is introduced, create specs and tests first.

Possible backend responsibilities:

- User profile and preferences
- Plan versions and progress history
- Food and exercise content library
- Admin content updates
- Analytics events
- Auth and consent

Use privacy-by-design:

- Collect minimum necessary personal data
- Encrypt sensitive data in transit
- Avoid logging health details
- Support deletion/export requests
- Keep analytics event names non-sensitive where possible
- Separate product analytics from health content

Define event schemas for:

- onboarding_started
- onboarding_completed
- plan_generated
- meal_guidance_viewed
- workout_started
- workout_completed
- safety_warning_shown
- weekly_review_completed

Do not add invasive tracking.

---

## Security and Privacy Requirements

Create a threat model before adding backend/auth.

Address:

- Sensitive health profile data
- Authentication and session security
- Secure local storage
- API authorization
- Input validation
- Dependency vulnerability scanning
- Secrets management
- Build signing and release safety
- Abuse cases such as unsafe plan generation or prompt injection if AI features are added

No secrets in repo. No hardcoded API keys. No sensitive user data in logs.

---

## DevOps and Release Requirements

Create a professional delivery path:

- Gradle build reproducibility
- Unit test and build commands documented
- CI workflow for test, lint, build, and security checks
- Debug and release build variants
- Versioning strategy
- Crash reporting plan, if added
- Play Store readiness checklist
- Internal QA release checklist

Prefer adding CI after the project structure stabilizes.

---

## QA Acceptance Gate

Before a slice is considered complete:

- Specs updated
- Tests written and passing
- App builds
- Critical UI path manually or automatically verified
- Accessibility basics checked
- Security/privacy risks reviewed
- Health safety language reviewed
- No unrelated refactors
- Summary includes files changed, tests run, and residual risks

---

## First Advanced Slice to Implement

Start by revisiting the MVP and implementing one professional-grade vertical slice:

Advanced Slice A: Safety-Aware Onboarding and Plan Generation

Acceptance criteria:

- User enters age, gender, height, weight, goal, activity, diet, training place, and medical cautions.
- If the user selects pregnancy, diabetes medication, heart symptoms, kidney disease, eating disorder history, or recent surgery, the app shows a medical review warning.
- Safe users receive calorie/protein targets, Pakistani meal guidance, workout plan, and habit nudges.
- Recommendation engine returns structured warnings separately from plan content.
- UI shows warnings clearly without panic language.
- Unit tests cover normal plan generation and each safety-warning trigger.
- Compose UI exposes the complete flow in a simple, accessible way.

After Slice A, propose the next best slice based on risk and value.

---

## Output Format for Each Agent Run

At the end of every run, report:

- Product/spec changes
- Architecture changes
- Implementation changes
- Tests added
- Commands run
- Pass/fail results
- Security/privacy notes
- Health safety notes
- Recommended next slice

Keep the response concise, but include exact file links and commands.

---

## Non-Negotiables

- Pakistani audience first.
- Specs before code.
- Tests before or alongside implementation.
- Health safety before engagement.
- Privacy before analytics.
- Accessibility before polish.
- Evidence-informed content before confidence.
- Working build before handoff.
