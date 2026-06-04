# MVP Revisited

## Current MVP

The current MVP is a Kotlin Android app using Jetpack Compose. It has a pure Kotlin recommendation engine that produces calories, protein, fiber, water, meal guidance, workout sessions, and habit nudges from goal, activity, diet pattern, training place, and body weight.

## Professional MVP Goal

The next MVP must become safety-aware. It should collect enough profile information to generate a more responsible starter plan, while remaining fast and approachable.

## Advanced Slice A: Safety-Aware Onboarding and Plan Generation

Inputs:

- Age
- Gender
- Height
- Weight
- Goal
- Activity level
- Diet pattern
- Training place
- Medical cautions

Medical caution options:

- Pregnancy
- Diabetes medication
- Heart symptoms
- Kidney disease
- Eating disorder history
- Recent surgery
- Knee pain or joint limitation

Advanced lifestyle options:

- Ramadan fasting
- Daawat or wedding week
- Budget-friendly groceries
- Office routine
- Eating out

Equipment options:

- Walking route
- No equipment
- Dumbbells
- Resistance band
- Gym machines

Outputs:

- Structured safety warnings
- Daily nutrition targets
- Pakistani meal guidance
- Meal timing guidance
- Budget grocery suggestions
- Workout plan
- Habit nudges

## Acceptance Criteria

### Scenario: Safe user receives a complete plan

Given a user has no selected medical cautions  
When the app generates a plan  
Then it returns no medical review warnings  
And it returns daily targets, Pakistani meal guidance, workout sessions, and habit nudges

### Scenario: Medical caution creates structured warning

Given a user selects pregnancy, diabetes medication, heart symptoms, kidney disease, eating disorder history, or recent surgery  
When the app generates a plan  
Then the recommendation engine returns a structured warning  
And the UI displays the warning separately from plan content

### Scenario: Joint limitation modifies workout

Given a user selects knee pain or joint limitation  
When the app generates a workout  
Then the plan avoids high-impact cardio and aggressive lower-body loading  
And it suggests gentler options such as walking, mobility, supported squats, or cycling

### Scenario: Lifestyle mode enriches plan

Given a user selects Ramadan, daawat, budget, office, or eating-out mode  
When the app generates a plan  
Then the plan includes mode-specific guidance  
And the guidance remains culturally realistic for Pakistani users
