# Functional Requirements

## Onboarding

- Collect age, gender, height, weight, goal, activity level, diet pattern, training place, and medical cautions.
- Collect lifestyle modes such as Ramadan fasting, daawat week, budget-friendly, office routine, and eating out.
- Collect equipment access such as walking route, no equipment, dumbbells, resistance band, and gym machines.
- Allow users to adjust inputs without restarting the flow.
- Generate plan immediately from current inputs.
- Collect optional health marker values for lipid profile, uric acid, fasting blood sugar, HbA1c, hemoglobin, and diabetes status.
- Calculate BMI and health marker report flags.
- Support calorie intake and calorie burn records.
- Support daily, weekly, and monthly record summaries.
- Support manual category and food item entry with calorie details.

## Recommendation Engine

- Calculate approximate calorie, protein, fiber, and hydration targets.
- Generate Pakistani meal guidance based on goal and diet pattern.
- Generate meal timing guidance based on Ramadan or standard routine.
- Generate grocery suggestions based on budget and diet pattern.
- Generate workout sessions based on goal, training place, and cautions.
- Generate workout sessions based on available equipment.
- Return safety warnings separately from plan content.
- Generate structured health reports separately from diagnosis or treatment language.

## Plan UI

- Show safety warnings before targets when warnings exist.
- Show daily targets in a scannable format.
- Show meal guidance, workout days, and habit nudges.
- Show meal timing and grocery suggestions when available.
- Show BMI and health marker flags when values are entered.
- Show meal calories, daily calories, calories burned, and period summaries.
- Show a Pakistani food catalog and manual food entry controls.
- Show an analysis dashboard with calorie, burn, net, meal count, progress, health flag, todo, and history summaries.
- Show charts/graphs for recent intake, burn, and net calorie trends.
- Generate todo suggestions from analysis signals.

## Acceptance Criteria

### Scenario: Plan updates when input changes

Given a user changes goal, activity, diet, training place, body size, or caution  
When the input changes  
Then the plan recalculates from the updated profile

### Scenario: Warning content is structured

Given the recommendation engine creates a warning  
When UI receives the result  
Then UI can read title, message, action, caution, and source category from separate fields

### Scenario: Lifestyle modes are additive

Given a user selects more than one lifestyle mode  
When the app generates a plan  
Then the plan combines relevant guidance without removing core targets

### Scenario: Manual food entry is loggable

Given a user adds a manual food item with category, serving, and calories  
When they log it into a meal  
Then daily calories and meal count update immediately

### Scenario: Dashboard reflects records and goals

Given food records, calorie targets, burn targets, and health flags  
When the analysis dashboard renders  
Then dashboard metrics, charts, trends, todos, and history update from the current data
