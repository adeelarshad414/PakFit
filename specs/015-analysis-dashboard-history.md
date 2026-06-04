# Analysis Dashboard, Charts, Progress, Todos, and History

## Slice D: Expert Analysis Experience

PakFit should help users understand patterns, not only enter data. The app must turn food records, calories burned, health reports, and plan targets into practical analysis.

## Functional Requirements

### Dashboard

The app must show a dashboard with:

- Daily calories consumed
- Daily calories burned
- Net calories
- Meal count
- Protein target progress estimate
- Calorie target progress
- Health marker review count
- Active todos

### Charts and Graphs

The app must show lightweight on-device visualizations:

- Bar chart for recent daily calorie intake
- Bar chart for recent calories burned
- Net calorie trend
- Progress bars for daily intake and burn goals
- Weekly and monthly summary cards

External charting libraries are optional. For the current MVP, custom Compose bars are acceptable.

### Trends

The analysis engine must produce:

- Calorie trend direction: improving, steady, or needs attention
- Burn trend direction: improving, steady, or needs attention
- Health marker risk count
- Adherence score from calorie target, burn target, meal logging, and todo completion

### Todos

The app must generate action-oriented todos based on dashboard signals:

- Log at least two meals if meal count is low
- Add a walk if calories burned are low
- Review health marker flags if present
- Add protein anchor if protein target progress is low
- Plan tomorrow's first meal if the day is off-track

Users should see todo status and a simple completed/pending count. The current MVP can keep todo state in memory or derive it from records.

### History

The app must show:

- Today summary
- Recent daily summaries
- Weekly summary
- Monthly summary
- Meal history for today

## Non-Functional Requirements

- Analytics calculations must be pure Kotlin and unit-testable without emulator.
- Charts must render without network access or third-party APIs.
- Calculations must be fast enough for instant UI updates.
- Dashboard text must avoid diagnosis or moral judgement.
- Visualizations must not rely on color alone; labels and numbers are required.
- Records remain in-memory until persistence is added.

## Acceptance Criteria

### Scenario: Dashboard summarizes the day

Given a daily food record, nutrition target, health report, and todo rules  
When the dashboard is generated  
Then it includes intake, burn, net calories, meal count, target progress, health flag count, and todos

### Scenario: Chart points are generated from history

Given multiple daily records  
When chart data is generated  
Then each day has intake, burn, and net calorie values  
And the chart labels are suitable for UI display

### Scenario: Trends identify off-track behavior

Given recent days exceed calorie target and miss burn target  
When trends are calculated  
Then calorie trend needs attention  
And burn trend needs attention

### Scenario: Todos respond to analysis

Given low meal count, low burn, low protein progress, and health flags  
When todos are generated  
Then the dashboard includes meal logging, walking, protein, and review-health-marker todos

### Scenario: History exposes recent records

Given records for several days  
When history is generated  
Then the latest records are ordered from newest to oldest  
And weekly/monthly summaries remain available
