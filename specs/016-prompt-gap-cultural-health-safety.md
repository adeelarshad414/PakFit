# Prompt Gap: Cultural and Health Safety Enhancements

## Slice E: Missing Prompt Requirements for the Android MVP

The attached FitPak/PakFit prompt contains platform-wide requirements. The current Android MVP already covers many Pakistani nutrition, workout, safety, food logging, and dashboard behaviors. This slice implements missing high-value Android/domain items that fit the current offline-first MVP.

## In Scope

- South Asian BMI cutoffs
- Halal flag on every food item
- Urdu medical disclaimer on health outputs
- Blood pressure tracking and review flags
- Emergency escalation for chest pain, BP above 180/120, or glucose above 400 mg/dL
- Prayer-aware workout timing notes

## Out of Scope for This Slice

- NestJS backend
- PostgreSQL/Redis/BullMQ/AWS EKS
- KMM shared module
- LangGraph/RAG AI layer
- JazzCash/Easypaisa SDK
- MediaPipe Pose
- Full Urdu RTL app migration
- Room/CRDT sync

These require separate architecture and dependency slices.

## Functional Requirements

### South Asian BMI

BMI classification must use South Asian cutoffs:

- Underweight: less than 18.5
- Healthy weight: 18.5 to 22.9
- Overweight: 23.0 to 27.4
- Obesity: 27.5 and above

### Halal Food Catalog

Every `FoodItem` must include an `isHalal` flag. The default Pakistani food catalog must be Halal by default.

### Urdu Medical Disclaimer

Every health report must expose the Urdu disclaimer:

`یہ معلومات طبی مشورہ نہیں ہے۔ ہمیشہ اپنے ڈاکٹر سے رجوع کریں۔`

The UI must show this disclaimer near health reports and warnings.

### Emergency Escalation

The app must create emergency escalation flags for:

- Chest pain or heart symptoms
- Systolic BP greater than or equal to 180 or diastolic BP greater than or equal to 120
- Fasting glucose greater than or equal to 400 mg/dL

Emergency flags must mention local Pakistani emergency options such as Rescue 1122, Edhi, or nearest emergency department.

### Prayer-Aware Workout Timing

Workout plans must include schedule notes that remind users not to start workouts inside prayer windows and to choose practical alternatives such as after Fajr, after Asr, after Isha, or after iftar during Ramadan.

## Non-Functional Requirements

- Health calculations remain pure Kotlin and unit-testable.
- No emergency logic may recommend medications.
- Emergency copy must be calm and clear.
- Halal metadata must be structured, not only text in labels.
- Prayer-aware scheduling must be data in the domain model, not only UI copy.

## Acceptance Criteria

### Scenario: BMI uses South Asian cutoffs

Given a Pakistani user has a BMI of 23.0 or higher  
When the app builds a BMI report  
Then the category is overweight  
And a BMI of 27.5 or higher is categorized as obesity

### Scenario: Food catalog is Halal by default

Given the default Pakistani food catalog is loaded  
When food items are inspected  
Then every food item has `isHalal = true`

### Scenario: Health output includes Urdu disclaimer

Given a health report is generated  
When the report is displayed  
Then it includes the Urdu medical disclaimer

### Scenario: Emergency values create escalation flags

Given a user reports chest pain, BP above 180/120, or glucose above 400 mg/dL  
When the health report is generated  
Then an emergency-level flag is returned  
And the message mentions Rescue 1122, Edhi, or emergency care

### Scenario: Workout timing respects prayer windows

Given a workout plan is generated  
When schedule notes are inspected  
Then the plan advises avoiding prayer windows  
And includes practical timing options for Pakistani users

## Source Categories

- WHO expert consultation on BMI action points for Asian populations
- CDC BMI screening context
- American Heart Association severe blood pressure emergency guidance
- ADA blood glucose context
- American Heart Association heart attack warning signs
