# Data Model Analytics and Events

## Current State

Current data is in-memory only. There is no persistence, backend, or analytics.

## Future Local Data Model

- User profile
- Medical cautions
- Optional health marker values
- Generated plan versions
- Food catalog items
- Manual food items
- Meal entries
- Calories burned
- Workout completions
- Weekly progress
- Food and exercise library content

## Future Analytics Events

Only add analytics after consent and privacy review.

- onboarding_started
- onboarding_completed
- plan_generated
- safety_warning_shown
- meal_guidance_viewed
- workout_started
- workout_completed
- weekly_review_completed

## Event Rules

- Avoid sending raw weight, medical cautions, or meal details in analytics.
- Avoid sending lipid profile, uric acid, blood sugar, HbA1c, hemoglobin, or diabetes status in analytics.
- Keep events aggregate and product-focused.
- Support deletion/export if accounts or backend storage are added.

## Acceptance Criteria

### Scenario: Analytics remains disabled in MVP

Given there is no consent flow  
When the user generates a plan  
Then no analytics event is emitted
