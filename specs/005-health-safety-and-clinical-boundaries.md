# Health Safety and Clinical Boundaries

## Boundary

PakFit provides education, planning, and habit support. It does not diagnose, treat disease, prescribe medical therapy, replace a doctor, replace a dietitian, or replace a physiotherapist.

## Source Categories

The current safety gate is conservative and based on these source categories:

- CDC physical activity guidance for chronic conditions: https://www.cdc.gov/physical-activity-basics/guidelines/chronic-health-conditions-and-disabilities.html
- ACOG physical activity guidance for pregnancy: https://www.acog.org/womens-health/faqs/exercise-during-pregnancy
- ADA blood glucose and exercise guidance: https://diabetes.org/health-wellness/fitness/blood-glucose-and-exercise
- American Heart Association getting active to control high blood pressure: https://www.heart.org/en/health-topics/high-blood-pressure/changes-you-can-make-to-manage-high-blood-pressure/getting-active-to-control-high-blood-pressure
- American Heart Association sodium and salt guidance: https://www.heart.org/en/healthy-living/healthy-eating/eat-smart/sodium/sodium-and-salt
- CDC sodium and health context: https://www.cdc.gov/salt/about/index.html
- NHLBI heart-healthy physical activity context: https://www.nhlbi.nih.gov/health/heart-healthy-living/physical-activity
- American Heart Association heart attack warning signs: https://www.heart.org/en/health-topics/heart-attack/warning-signs-of-a-heart-attack
- CDC kidney disease self-care guidance: https://www.cdc.gov/kidney-disease/living-with/index.html
- National Eating Disorders Association excessive exercise guidance: https://www.nationaleatingdisorders.org/excessive-exercise/
- CDC getting started with physical activity: https://www.cdc.gov/healthy-weight-growth/physical-activity/getting-started.html

## Safety Rules

| Caution | App Action | Reason |
| --- | --- | --- |
| Pregnancy | Medical review warning plus plan modification | Pregnancy can be safe for activity, but complications require clinician evaluation; ordinary fat-loss deficits and aggressive workout labels should pause. |
| Diabetes medication | Medical review warning | Exercise can affect blood glucose and some medicines increase low-glucose risk. |
| High blood pressure | Plan modification warning | Lower-sodium food guidance and moderate conversational movement are safer defaults, while medicines and repeated readings require clinician review. |
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

### Scenario: Pregnancy modifies plan output

Given a user selects pregnancy and fat loss
When the recommendation engine builds a plan
Then the plan pauses the fat-loss calorie deficit
And the workout title does not present fat loss
And nutrition and movement guidance require obstetric clinician review

### Scenario: High blood pressure modifies plan output

Given a user selects high blood pressure and Ramadan fasting
When the recommendation engine builds a plan
Then the plan avoids salted-lassi hydration guidance
And the workout title uses blood pressure clinician-reviewed movement
And the guidance tells users not to self-adjust BP medicines

### Scenario: Warning language is calm

Given the app shows a medical review warning  
When the user reads it  
Then the copy is clear and calm  
And it does not use panic language
