# Domain Model and Recommendation Rules

## Domain Types

- `UserProfile`
- `Goal`
- `ActivityLevel`
- `DietPattern`
- `TrainingPlace`
- `MedicalCaution`
- `LifestyleMode`
- `EquipmentAccess`
- `SafetyWarning`
- `FitnessPlan`
- `PlanRecommendation`

## Recommendation Rule Summary

- Calories are estimated from profile size, age, gender, activity, and goal.
- Protein increases for fat loss and muscle gain.
- Pakistani meal guidance changes by diet pattern.
- Meal timing guidance changes by lifestyle modes.
- Grocery suggestions change by budget mode and diet pattern.
- Workout sessions change by training place.
- Knee or joint limitation modifies workout selection.
- Equipment access modifies workout selection.
- Safety warnings are returned separately from plan content.

## Warning Rule Table

| Caution | Warning Action |
| --- | --- |
| Pregnancy | Medical review |
| Diabetes medication | Medical review |
| Heart symptoms | Medical review |
| Kidney disease | Medical review |
| Eating disorder history | Medical review |
| Recent surgery | Medical review |
| Knee pain or joint limitation | Modify plan |

## Lifestyle Rule Table

| Mode | Plan Effect |
| --- | --- |
| Ramadan fasting | Adds suhoor, iftar, hydration, and after-iftar training guidance |
| Daawat or wedding week | Adds event meal strategy without shame language |
| Budget-friendly | Adds affordable Pakistani grocery suggestions |
| Office routine | Adds chai, walking, desk mobility, and lunch habit anchors |
| Eating out | Adds local restaurant and canteen selection strategy |

## Equipment Rule Table

| Equipment | Plan Effect |
| --- | --- |
| Walking route | Supports walking/cardio sessions |
| No equipment | Uses bodyweight and household movements |
| Dumbbells | Adds dumbbell strength movements |
| Resistance band | Adds band rows, presses, and mobility |
| Gym machines | Allows machine-based gym sessions |

## Acceptance Criteria

### Scenario: Safe result has empty warnings

Given no medical cautions  
When `buildRecommendation` runs  
Then `warnings` is empty

### Scenario: Warning result still has structured plan

Given a medical caution  
When `buildRecommendation` runs  
Then `warnings` is not empty  
And `plan` remains available for UI rendering
