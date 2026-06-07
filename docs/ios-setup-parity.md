# PakFit iOS Setup Parity

The iOS app now includes a Setup workflow so Pakistani users can update profile and plan inputs without relying on Android-only setup behavior.

## Current iOS Setup Scope

- Theme mode selection for system, light, and dark appearance.
- Adult age floor controls for 18 and older, plus height and weight steppers.
- The adult age floor keeps the iOS setup workflow aligned with PakFit's adult-use safety boundary.
- Gender, goal, activity level, diet pattern, and training place controls.
- Editable lifestyle modes for Ramadan fasting, daawat or wedding weeks, budget-friendly planning, office routines, and eating out.
- Editable medical cautions for pregnancy, diabetes medication, heart symptoms, kidney disease, eating-disorder history, recent surgery, and knee or joint limitations.
- Profile summary showing calorie target, protein target, workout days, and safety warning count.

## Product Rule

Setup changes must update the shared iOS recommendation model immediately so Dashboard, Plan, Health, local snapshot export, and adult-use safety warnings all use the same current profile.

## Release Boundary

This static gate proves source-level parity. Final production release still needs device QA for the Setup tab on iPhone sizes, VoiceOver, large text, and signed production builds.
