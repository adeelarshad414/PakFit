# Product Vision

## Purpose

PakFit is a Pakistani-first Android coaching app for practical fitness, workouts, and nutrition. It helps users build safe, repeatable routines around familiar foods, family meals, office schedules, home workouts, gym access, Ramadan, daawat culture, and budget constraints.

## Target Users

- Pakistani office workers, students, homemakers, and beginners.
- Users seeking fat loss, muscle gain, strength, stamina, or general wellness.
- Users who eat familiar foods such as roti, rice, daal, chana, eggs, chicken karahi, biryani, nihari, dahi, raita, lassi, chai, fruit chaat, and paratha.
- Users who need home, walking, stairs, dumbbell, resistance-band, or gym options.

## Product Principles

- Pakistani audience first.
- Health safety before engagement.
- Respectful, non-shaming language.
- Practical portions over banned-food lists.
- Evidence-informed guidance with explicit medical boundaries.
- Privacy before analytics.
- Accessibility before visual polish.

## Acceptance Criteria

### Scenario: Pakistani user recognizes the plan

Given a user generates a plan  
When they read nutrition guidance  
Then it references local foods, portions, and routines  
And it avoids generic meal examples that ignore Pakistani context

### Scenario: Safety-sensitive user is not overconfidently coached

Given a user selects a medical caution  
When the app generates a plan  
Then the app shows a medical review warning  
And the warning is separate from general coaching content
