# Phase 2 Clinical Intelligence MVP

## Prompt Context

The attached Phase 2 FitPak prompt asks for an advanced health platform: AI agents, clinical reasoning, telehealth, lab integrations, wearables, FHIR export, social features, backend services, observability, security hardening, and professional DevOps.

The current repository is an Android-only Jetpack Compose MVP. This slice implements the missing features that can be delivered honestly inside the app today, while documenting that backend, ML, integrations, and regulated clinical workflows require separate implementation slices.

## In Scope

- On-device rule-based predictive screening insights for Pakistani/South Asian users.
- Clinical risk summaries for type 2 diabetes, hypertension, cardiovascular risk, vitamin D deficiency risk, iron-deficiency anemia risk, and PCOS metabolic/reproductive screening.
- Urdu and English explanations for each screening insight.
- Action steps that encourage doctor review, lab follow-up, safe lifestyle changes, and food-first Pakistani guidance.
- PHQ-9 and GAD-7 score interpretation for mental wellness screening.
- Crisis escalation when the user reports self-harm thoughts, inability to stay safe, or severe distress.
- Pakistan crisis and emergency contact resources in the app.
- Compose UI controls and report cards for the above.
- Unit tests for every domain behavior.

## Out of Scope

- Diagnosis, prescribing, medicine dose changes, or emergency triage beyond escalation prompts.
- ML models, TFLite, federated learning, model registry, or health twin simulation.
- Telehealth scheduling, doctor marketplace, prescriptions, insurance, or payment integrations.
- Direct lab provider integration, wearable sync, FHIR export, or EHR integration.
- NestJS backend, PostgreSQL, Redis, BullMQ, Kafka, AWS EKS, IaC, and SRE automation.
- Full Urdu RTL localization, voice input, image-based food recognition, and multimodal AI.

These are important professional-grade platform requirements, but they need separate specs, architecture decisions, threat models, and backend/mobile integration work.

## Functional Requirements

### Clinical Risk Inputs

The app must collect optional user-selected risk factors:

- Family history of type 2 diabetes
- Family history of high blood pressure
- Family history of early heart disease
- High-salt routine
- Low sun exposure
- Low-iron diet
- Heavy periods or blood loss
- Smoking or tobacco exposure

### Predictive Screening Insights

The app must generate screening insights for:

- Type 2 diabetes risk
- Hypertension risk
- Cardiovascular risk
- Vitamin D deficiency risk
- Iron-deficiency anemia risk
- PCOS metabolic/reproductive screening

Each insight must include:

- Risk type
- Risk level
- Numeric score
- English title
- English explanation
- Urdu explanation
- Action steps
- Source category

### Safety Boundaries

The app must never label a user as diagnosed from risk factors alone. All wording must say screening, risk, review, or follow-up. Emergency symptoms and critical markers remain handled by the existing health report escalation logic.

### Mental Wellness Screening

The app must support:

- PHQ-9 score interpretation from either item responses or a direct score.
- GAD-7 score interpretation from either item responses or a direct score.
- Screening language only, not diagnosis.
- Recommended next steps based on severity.
- A bilingual disclaimer.

PHQ-9 severity bands:

- 0 to 4: Minimal
- 5 to 9: Mild
- 10 to 14: Moderate
- 15 to 19: Moderately severe
- 20 to 27: Severe

GAD-7 severity bands:

- 0 to 4: Minimal
- 5 to 9: Mild
- 10 to 14: Moderate
- 15 to 21: Severe

### Crisis Escalation

The app must show crisis resources when:

- The user reports self-harm thoughts.
- PHQ-9 item 9 is greater than 0.
- The user says they cannot stay safe.
- The user reports panic or severe distress.

Crisis resources must include Pakistan-specific options such as:

- Rescue 1122 or mobile 112 for ambulance/emergency response.
- Police 15 when immediate safety is threatened.
- Umang Pakistan mental health helpline.
- Rozan counselling contact options.

The copy must encourage staying near a trusted person and contacting local emergency care when immediate safety is at risk.

## Non-Functional Requirements

- All clinical and mental wellness calculations must be pure Kotlin and unit-testable.
- The app must work offline using local rule engines.
- No new network permission is required for this slice.
- Health data remains in memory in the current MVP; persistent storage/encryption requires a future privacy slice.
- Copy must be calm, culturally relevant, and suitable for Pakistani users.
- No medication, supplement dosage, or fasting-with-medication recommendation may be given.
- The implementation must be deterministic so tests can lock down safety behavior.

## Acceptance Criteria

### Scenario: Diabetes risk insight

Given a Pakistani user has South Asian overweight/obesity, a family history of diabetes, and elevated HbA1c  
When clinical intelligence insights are generated  
Then type 2 diabetes risk is high  
And the insight includes Urdu explanation and doctor-review action steps

### Scenario: Hypertension risk insight

Given a user has elevated blood pressure, high-salt routine, and family history of hypertension  
When insights are generated  
Then hypertension risk is high  
And the insight does not diagnose hypertension

### Scenario: Cardiovascular risk insight

Given lipid flags, blood pressure risk, diabetes status, and smoking/tobacco exposure  
When insights are generated  
Then cardiovascular risk is high  
And action steps include clinician review

### Scenario: Vitamin D risk insight

Given low sun exposure and higher BMI  
When insights are generated  
Then vitamin D deficiency risk is raised  
And action steps recommend safe sun exposure, food sources, and doctor/lab review

### Scenario: Iron-deficiency anemia risk insight

Given a female user has low hemoglobin and heavy periods or low-iron diet  
When insights are generated  
Then iron-deficiency anemia risk is high  
And action steps include clinician review and iron-rich Pakistani foods

### Scenario: PCOS metabolic/reproductive screening insight

Given a female user has irregular or missed periods, excess hair or persistent acne, higher BMI, and elevated HbA1c
When insights are generated
Then PCOS metabolic/reproductive screening risk is high
And action steps include clinician review and a warning not to self-start hormones, metformin, fertility medicines, or supplements

### Scenario: Mental wellness scoring

Given PHQ-9 score is 15 and GAD-7 score is 16  
When mental wellness screening is generated  
Then PHQ-9 is moderately severe  
And GAD-7 is severe  
And the report states screening is not diagnosis

### Scenario: Crisis support

Given self-harm thoughts or inability to stay safe is selected  
When mental wellness screening is generated  
Then crisis escalation is shown  
And Pakistan emergency and mental health resources are listed

## Source Categories

- CDC diabetes risk factor guidance
- NHLBI high blood pressure risk factor guidance
- NHLBI heart disease risk factor guidance
- NIH Office of Dietary Supplements vitamin D fact sheet
- NHLBI anemia causes and risk factor guidance
- NICHD PCOS symptom guidance
- CDC PCOS and diabetes risk guidance
- APA PHQ-9 adapted severity measure and scoring guidance
- University of Washington HIV Curriculum GAD-7 scoring guidance
- WHO Eastern Mediterranean Region Pakistan crisis resources
- Rescue 1122 official emergency service information
- Umang Pakistan helpline information
