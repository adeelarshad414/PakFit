# PakFit iOS Lifestyle Coach Parity

The iOS Dashboard now gives Pakistani users editable daily lifestyle inputs and a dynamic coach review instead of static todo text.

The editable set covers calories burned, water, steps, sleep, workout minutes, and stress.

## Current iOS Daily Controls

- Calories burned today.
- Water intake.
- Steps.
- Sleep hours.
- Workout minutes.
- Stress level.

## Coach Review Logic

The iOS coach review uses the shared Swift `CoachReviewEngine` to score daily behavior and generate prioritized actions across nutrition, meal timing, hydration, activity, recovery, and health safety.

The review reacts to food logs, calorie burn, water, steps, sleep, workout minutes, stress, and health flags. It shows a score, strengths, and next actions so the Dashboard becomes a practical daily coaching workflow rather than a static summary.

## Product Rule

Daily lifestyle edits must update `PakFitViewModel.lifestyleRecord`, the secure local snapshot, and the visible Daily Coach Review in the same session. The workflow stays local-first and non-diagnostic.

## Release Boundary

This static gate proves source-level iOS lifestyle coach parity. Final production release still needs iPhone device QA, VoiceOver, large-text review, and coach-copy review with a qualified health and nutrition reviewer.
