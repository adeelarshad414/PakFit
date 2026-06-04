# Advanced Use Cases

## Slice B: Pakistani Lifestyle Modes

The next product step is to move beyond generic plan generation and support real Pakistani lifestyle situations.

## Use Case 1: Ramadan Fasting Mode

User wants a plan during Ramadan.

Functional requirements:

- Add Ramadan fasting as a selectable lifestyle mode.
- Show suhoor and iftar meal timing guidance.
- Emphasize hydration between iftar and suhoor.
- Suggest lighter training while fasting and strength/cardio after iftar when appropriate.
- If diabetes medication is also selected, show a Ramadan-specific medical review warning.

Acceptance criteria:

### Scenario: Ramadan plan includes fasting-aware timing

Given the user selects Ramadan fasting  
When the app generates a plan  
Then the plan includes suhoor guidance  
And iftar guidance  
And hydration guidance between iftar and suhoor

### Scenario: Diabetes medication plus Ramadan creates specific warning

Given the user selects Ramadan fasting and diabetes medication  
When the app generates warnings  
Then a warning mentions fasting safety  
And the source category references Ramadan diabetes guidance

## Use Case 2: Daawat and Wedding Week Mode

User has family meals, wedding events, or daawat meals and wants portion strategy without shame.

Functional requirements:

- Add daawat/weekend event mode.
- Give plate-order strategy: protein and salad first, then rice/roti/dessert portion.
- Avoid words like cheat, guilt, punish, or compensate.

Acceptance criteria:

### Scenario: Daawat mode avoids shame language

Given the user selects daawat mode  
When the app generates meal guidance  
Then guidance includes a daawat strategy  
And it does not use shame-based language

## Use Case 3: Budget Grocery Mode

User needs high-protein Pakistani meals with affordable foods.

Functional requirements:

- Add budget-friendly mode.
- Generate a grocery list with local affordable protein and fiber options.
- Respect vegetarian and egg-friendly diet patterns.

Acceptance criteria:

### Scenario: Budget vegetarian plan uses affordable local proteins

Given the user selects vegetarian and budget mode  
When the app generates a plan  
Then the grocery list includes daal, chana, lobia, dahi, or soy  
And it does not require supplements

## Use Case 4: Office Routine Mode

User sits most of the day and needs small habit anchors.

Functional requirements:

- Add office routine mode.
- Suggest chai strategy, post-meal walking, desk mobility, and lunch portion anchors.

Acceptance criteria:

### Scenario: Office mode adds habit anchors

Given the user selects office routine mode  
When the app generates habit nudges  
Then nudges include chai, walking, and desk mobility or sitting-break guidance

## Use Case 5: Eating Out Mode

User frequently eats at restaurants, canteens, or roadside food spots.

Functional requirements:

- Add eating-out mode.
- Suggest Pakistani restaurant choices such as tikka, grilled fish, daal, chana chaat, raita, and portioned biryani.

Acceptance criteria:

### Scenario: Eating-out mode gives local options

Given the user selects eating-out mode  
When the app generates meal guidance  
Then it suggests local restaurant/canteen choices  
And avoids banning foods outright

## Use Case 6: Equipment-Aware Workouts

User has different equipment access.

Functional requirements:

- Add equipment access choices: walking route, no equipment, dumbbells, resistance band, and gym machines.
- Home workout should adapt to available equipment.
- Gym workout should use machines only when gym machines are available.

Acceptance criteria:

### Scenario: Dumbbell home user gets dumbbell exercises

Given the user trains at home and selects dumbbells  
When the app generates a workout  
Then at least one session uses dumbbell exercises

### Scenario: No-equipment user avoids dumbbell-specific instructions

Given the user trains at home and selects no equipment  
When the app generates a workout  
Then the workout does not require dumbbells or machines
