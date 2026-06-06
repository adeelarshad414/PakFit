# Online Food Search and Photo Calorie Estimator

## Context

The product now needs online food search and a camera-based food calorie workflow. A Meta-like image calorie feature requires an actual computer-vision model, backend, or device ML model. This repository is currently an Android-only MVP with no backend and no image-recognition model. This slice adds the production-safe foundation:

- Internet permission.
- Online calorie search handoff.
- Camera capture/preview.
- Deterministic calorie estimate based on food hint, selected catalog item, and portion size.
- Clear confidence and upgrade boundary.

## In Scope

- Add Android internet and camera permissions.
- Add a food calorie web search feature from the tracker workflow.
- Add camera capture for a food photo preview.
- Add food hint and portion selector for photo-assisted calorie estimate.
- Add domain tests for URL generation and calorie estimation.
- Add release validation that fails if food photo bytes are persisted or uploaded before a reviewed vision/backend design exists.

## Out of Scope

- Real AI vision inference.
- Backend image upload.
- User account storage.
- OCR, segmentation, plate detection, or ingredient recognition.

## Functional Requirements

### Online Food Search

The app must build an online search URL using:

- User query
- "calories"
- "Pakistani food" context

The URL must safely encode spaces and punctuation.

### Food Photo Capture

The app must let the user capture a food photo and show the preview in the Tracker workflow.
The current release must keep captured food photos ephemeral and preview-only.

### Photo Calorie Estimate

The app must estimate calories from:

- Food hint text
- Matching catalog food item when available
- Portion size: small, medium, or large

The result must include:

- Food display name
- Estimated calories
- Confidence
- Explanation
- Online verification query

## Acceptance Criteria

### Scenario: Search URL is encoded

Given the user searches "chicken biryani 1 plate"  
When the search URL is built  
Then it contains encoded calorie and Pakistani food context

### Scenario: Known food photo estimate uses catalog calories

Given the food hint is "chicken biryani" and portion is large  
When the photo estimate is generated  
Then calories are based on the catalog biryani value and large portion multiplier
And confidence is high

### Scenario: Unknown food photo estimate stays conservative

Given the food hint does not match the catalog  
When the photo estimate is generated  
Then confidence is low  
And the app provides an online verification query

### Scenario: Food photo privacy stays local

Given the release validation command runs
When the app source is inspected
Then photo capture remains preview-only
And app code does not persist or upload food photo image bytes
