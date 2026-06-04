# Holistic Daily Coach Review

## Context

Production health and fitness apps should not only collect data. They should turn food, activity, hydration, sleep, stress, and health safety signals into clear next actions. PakFit already has food logging, dashboards, health markers, clinical screening, and mental wellness screening. This slice adds a daily coaching layer that helps the user decide what to do next.

## In Scope

- Add daily lifestyle inputs:
  - Water consumed
  - Steps
  - Sleep
  - Workout minutes
  - Stress level
- Add a pure Kotlin coach review engine.
- Generate a daily coach score.
- Generate strengths and action items across:
  - Nutrition
  - Meal timing
  - Activity
  - Hydration
  - Recovery
  - Health safety
- Add dashboard UI for lifestyle inputs and coach review.
- Keep all advice non-diagnostic and non-prescriptive.

## Out of Scope

- Wearable sync.
- Automated notifications.
- Persistent habits.
- Clinical decision support beyond existing review/escalation prompts.

## Functional Requirements

### Nutrition Quality

The coach review should inspect today food entries for:

- Meal count
- Protein anchor presence
- Sabzi/salad presence
- Dessert or sugary drink load

### Activity

The coach review should inspect steps, workout minutes, and calories burned.

### Hydration

The coach review should compare water consumed against the user's daily water target.

### Recovery

The coach review should inspect sleep and stress.

### Health Safety

The coach review should surface health flags as a clinician-review action, not a workout challenge.

## Acceptance Criteria

### Scenario: Low recovery and hydration create actions

Given the user logs low water, low steps, low sleep, and health flags  
When the coach review is generated  
Then hydration, activity, recovery, and health-safety actions are present  
And the daily coach score is below 70

### Scenario: Balanced day creates high score and strengths

Given the user logs multiple meals with protein and sabzi, enough water, enough steps, enough sleep, and a workout  
When the coach review is generated  
Then the daily coach score is at least 80  
And strengths mention protein, hydration, activity, and recovery

### Scenario: Food quality detects sweets and missing protein

Given the user logs dessert or sweet drinks without a protein anchor  
When the coach review is generated  
Then the action list includes a protein anchor action  
And a sweets or sugary drinks action
