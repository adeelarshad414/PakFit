# English UI, Theme Mode, and Hourly Calorie Tracking

## Context

The latest product direction removes Urdu from the current app experience and asks for a more professional UI with both dark and light modes. The calorie tracker must also support everyday use where users can add every food item by meal and by hour.

## In Scope

- Remove Urdu copy from app models, UI, tests, and README.
- Keep English-only medical disclaimers and screening boundaries.
- Add a light/dark theme mode selector inside the app.
- Update hardcoded UI colors so cards, progress bars, warnings, and crisis states work in both themes.
- Extend daily food logging so each entry has:
  - Meal name
  - Time/hour label
  - Food item
  - Servings
  - Calories
- Add daily calorie tracker output with:
  - Daily summary
  - Hourly calorie breakdown
  - Meal-wise calorie breakdown
  - Newest-first food history

## Out of Scope

- Persistent storage.
- Calendar navigation between days.
- Backend sync.
- Widgets and push reminders.

These require a separate persistence and notification slice.

## Functional Requirements

### English-Only Health Copy

Health reports, clinical screening, and mental wellness reports must expose English copy only. The app must not display Urdu disclaimers, Urdu explanations, or Urdu crisis messages.

### Theme Mode

The app must let the user choose Light or Dark mode. Both modes must keep readable contrast for:

- Page background
- Cards
- Text
- Chips
- Progress bars
- Health warnings
- Crisis support state

### Daily Calorie Tracker

The food tracker must let users log every food item with a meal name and a time label. The engine must group entries by hour and by meal so the UI can show calories throughout the day and meal-wise totals.

## Acceptance Criteria

### Scenario: Health reports are English only

Given a health report is generated  
When it is displayed in the app  
Then it includes an English medical disclaimer  
And no Urdu disclaimer is exposed

### Scenario: Clinical insights are English only

Given clinical intelligence insights are generated  
When insight data is inspected  
Then each insight has English explanation and action steps  
And no Urdu explanation field is required

### Scenario: Mental wellness crisis message is English only

Given crisis support is needed  
When the mental wellness report is generated  
Then the crisis message is English  
And Pakistan crisis resources are still shown

### Scenario: Food is tracked by meal and hour

Given a user logs breakfast at 08:00, lunch at 13:00, and dinner at 21:00  
When the daily calorie tracker is generated  
Then hourly totals are returned for 08:00, 13:00, and 21:00  
And meal-wise totals are returned for Breakfast, Lunch, and Dinner  
And entries are shown newest first
