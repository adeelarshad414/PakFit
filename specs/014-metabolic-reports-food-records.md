# Metabolic Reports and Food Records

## Slice C: Health Markers, Reports, Pakistani Food Catalog, and Records

PakFit must evolve from one-time plan generation into an offline-first tracking and reporting tool.

## Functional Requirements

### Health Reports

The app must calculate and display:

- BMI value and BMI category
- Lipid profile review flags for total cholesterol, LDL, HDL, and triglycerides
- Uric acid review flag
- Blood sugar and HbA1c review flags
- Hemoglobin review flag
- Diabetes status as a user-selected profile condition

Health reports must not diagnose disease. They should say "review with your doctor" when values are outside conservative screening ranges or when the user already has diabetes.

### Calories and Records

The app must support:

- Daily calorie intake
- Daily calorie burn
- Meal count
- Meal-level calories
- Daily summary
- Weekly summary
- Monthly summary

For this MVP slice, records can remain in memory. Persistence with Room or backend sync should be specified later.

### Pakistani Food Catalog

The app must include a starter food catalog covering:

- Roti, paratha, naan, rice
- Daal, chana, lobia
- Chicken, beef, fish, eggs
- Sabzi and salad
- Dahi, raita, lassi
- Biryani, karahi, nihari, haleem, tikka, kebab, pulao
- Desserts such as kheer, gulab jamun, jalebi, ras malai, sheer khurma
- Drinks such as chai, doodh patti, lassi, rooh afza, sugar-free drinks, water
- Snacks such as samosa, pakora, chana chaat, fruit chaat

### Manual Food Entry

The app must allow the user to add:

- Category
- Food item name
- Serving description
- Calories per serving

Manual food items should be available for meal logging immediately in memory.

## Non-Functional Requirements

- Calculations must be pure Kotlin and unit-testable without emulator.
- Health marker thresholds must be documented and source categories recorded.
- UI must remain responsive and offline-first.
- No health marker values, meal logs, or manual foods should be sent to a backend in this MVP.
- The UI must distinguish "screening/report flag" from "diagnosis".
- Food catalog data must be structured so future persistence/admin editing is possible.

## Acceptance Criteria

### Scenario: BMI report is calculated

Given a user has height and weight  
When the app generates a health report  
Then BMI value and category are shown  
And the report says BMI is a screening measure

### Scenario: Metabolic markers create review flags

Given cholesterol, uric acid, blood sugar, HbA1c, or hemoglobin values are outside conservative screening ranges  
When the app generates a health report  
Then it returns structured review flags  
And the flags include source categories

### Scenario: Pakistani catalog covers major food groups

Given the default catalog is loaded  
When categories are inspected  
Then it includes roti/rice/bread, daal/legumes, protein, sabzi, dairy, desi dishes, desserts, drinks, and snacks

### Scenario: Manual food item is added

Given the user enters category, food name, serving, and calories  
When the item is added  
Then the item appears in the catalog  
And can be used in a meal entry

### Scenario: Daily, weekly, monthly summaries calculate calories

Given meal entries and calories burned for multiple days  
When summaries are generated  
Then daily, weekly, and monthly totals include intake, burn, net calories, and meal count

## Source Categories

- CDC BMI categories: https://www.cdc.gov/bmi/adult-calculator/bmi-categories.html
- CDC cholesterol/lipid profile: https://www.cdc.gov/cholesterol/about/index.html
- ADA diabetes diagnosis thresholds: https://diabetes.org/about-diabetes/diagnosis
- NIAMS gout and urate context: https://www.niams.nih.gov/health-topics/gout
- Mayo Clinic Laboratories uric acid reference context: https://www.mayocliniclabs.com/test-catalog/overview/8440
- NHLBI anemia and hemoglobin context: https://www.nhlbi.nih.gov/health/anemia/diagnosis
