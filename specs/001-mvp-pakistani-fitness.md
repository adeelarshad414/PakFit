# PakFit MVP Spec

## Product Intent

PakFit is an Android fitness and nutrition coach for Pakistani users who want realistic guidance without abandoning familiar foods, family meals, office routines, or home-based training.

The MVP should generate a starter plan from a few inputs:

- Goal: fat loss, muscle gain, or general fitness
- Activity level: mostly sitting, walks sometimes, or active routine
- Diet pattern: halal omnivore, vegetarian, or egg friendly
- Training place: home or gym
- Body weight

## Audience Assumptions

- Users commonly eat roti, rice, daal, eggs, chicken, chana, biryani, karahi, raita, lassi, and chai.
- Many users need home workout options with bodyweight, stairs, walking, dumbbells, or a loaded backpack.
- Advice must feel practical for Pakistani family meals, daawat culture, and late dinners.
- The app should avoid shame language and focus on portion control, protein anchoring, and repeatable habits.

## Acceptance Criteria

### Scenario: Fat loss user gets Pakistani meal guidance

Given a Pakistani user selects fat loss  
When the app generates a plan  
Then the plan includes daily calorie and protein targets  
And the meal guidance mentions roti or rice portions  
And the plan includes realistic swaps for lassi, biryani, or chai

### Scenario: Vegetarian user gets local protein options

Given a user selects vegetarian  
When the app generates meal guidance  
Then the plan suggests local options such as daal, chana, paneer, dahi, soy, tofu, or lobia

### Scenario: Home training user gets no-gym workouts

Given a user selects home training  
When the app generates a workout  
Then the plan uses bodyweight, walking, stairs, dumbbells, or backpack movements  
And it does not depend on gym machines

### Scenario: Muscle gain user gets higher protein and calories

Given the same user profile  
When comparing fat loss and muscle gain goals  
Then the muscle gain plan has a higher calorie target  
And the muscle gain plan has a higher protein target

## Test Strategy

The first tests live at the domain layer because recommendation quality is the product core.

- Unit tests assert Pakistani meal guidance terms and portion behavior.
- Unit tests compare calories and protein across goals.
- Unit tests verify home workout constraints.
- Compose UI should stay thin and consume the tested recommendation engine.

## Agentic Development Loop

1. Add or update a spec scenario.
2. Write the smallest failing unit test that encodes the scenario.
3. Implement domain behavior until tests pass.
4. Wire the behavior into Compose UI.
5. Run unit tests and build checks before adding the next feature.

Future slices should follow the same loop for Ramadan mode, PCOS-friendly guidance, diabetes-risk guidance, grocery budget mode, and Urdu/Roman Urdu copy support.
