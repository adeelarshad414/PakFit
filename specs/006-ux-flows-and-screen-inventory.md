# UX Flows and Screen Inventory

## Current Slice Flow

The current advanced slice remains a single Compose screen for speed:

1. Header and safety positioning
2. Profile controls
3. Goal and lifestyle controls
4. Diet and training controls
5. Medical caution chips
6. Safety warnings
7. Plan summary

## Future Screens

- Welcome and safety notice
- Profile setup
- Goal and lifestyle intake
- Diet preferences and budget
- Workout constraints and equipment
- Plan summary
- Meal plan detail
- Workout week detail
- Progress dashboard
- Settings and localization

## UI Requirements

- Use chips for categorical choices.
- Use sliders for numeric values in the current prototype.
- Show warnings before plan details.
- Avoid in-app marketing copy.
- Keep text concise and action-oriented.

## Acceptance Criteria

### Scenario: User sees warning before plan

Given warnings exist  
When the plan screen renders  
Then warning cards appear before daily targets

### Scenario: User can create plan without scrolling confusion

Given the app has multiple inputs  
When the user scrolls  
Then cards are ordered from profile to cautions to result
