# Health Safety and Clinical Boundaries

## Boundary

PakFit provides education, planning, and habit support. It does not diagnose, treat disease, prescribe medical therapy, replace a doctor, replace a dietitian, or replace a physiotherapist.

## Source Categories

The current safety gate is conservative and based on these source categories:

- CDC physical activity guidance for chronic conditions: https://www.cdc.gov/physical-activity-basics/guidelines/chronic-health-conditions-and-disabilities.html
- ACOG physical activity guidance for pregnancy: https://www.acog.org/womens-health/faqs/exercise-during-pregnancy
- ADA blood glucose and exercise guidance: https://diabetes.org/health-wellness/fitness/blood-glucose-and-exercise
- American Heart Association heart attack warning signs: https://www.heart.org/en/health-topics/heart-attack/warning-signs-of-a-heart-attack
- CDC kidney disease self-care guidance: https://www.cdc.gov/kidney-disease/living-with/index.html
- National Eating Disorders Association excessive exercise guidance: https://www.nationaleatingdisorders.org/excessive-exercise/
- CDC getting started with physical activity: https://www.cdc.gov/healthy-weight-growth/physical-activity/getting-started.html

## Safety Rules

| Caution | App Action | Reason |
| --- | --- | --- |
| Pregnancy | Medical review warning | Pregnancy can be safe for activity, but complications require clinician evaluation. |
| Diabetes medication | Medical review warning | Exercise can affect blood glucose and some medicines increase low-glucose risk. |
| Heart symptoms | Medical review warning | Chest discomfort, shortness of breath, and related symptoms require medical evaluation. |
| Kidney disease | Medical review warning | Activity and protein targets may need clinician or dietitian tailoring. |
| Eating disorder history | Medical review warning | Dieting, tracking, and exercise can worsen risk for some users. |
| Recent surgery | Medical review warning | Return to training depends on surgical clearance and recovery. |
| Knee pain or joint limitation | Plan modification warning | Workouts should reduce impact and aggressive knee loading. |

## Acceptance Criteria

### Scenario: Medical caution is separated from coaching

Given a user selects a medical caution  
When a recommendation is generated  
Then safety warnings appear in structured warning fields  
And the app does not hide the warning inside meal or workout guidance

### Scenario: Warning language is calm

Given the app shows a medical review warning  
When the user reads it  
Then the copy is clear and calm  
And it does not use panic language
