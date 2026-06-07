#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IOS_APP="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PakFitScreens.swift"
IOS_MODELS="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitModels.swift"
IOS_ENGINES="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitEngines.swift"
IOS_SMOKE_TESTS="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCoreSmokeTests/main.swift"
DOC_FILE="$ROOT_DIR/docs/ios-lifestyle-coach-parity.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"

for required_file in "$IOS_APP" "$IOS_MODELS" "$IOS_ENGINES" "$IOS_SMOKE_TESTS" "$DOC_FILE" "$STORE_LISTING"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing iOS lifestyle coach parity gate input: $required_file" >&2
    exit 1
  fi
done

require_text() {
  local file="$1"
  local text="$2"
  local description="$3"
  if ! grep -Fq "$text" "$file"; then
    echo "$description is missing from $file: $text" >&2
    exit 1
  fi
}

require_text "$IOS_MODELS" "public enum CoachingArea" "iOS coach area model"
require_text "$IOS_MODELS" "public enum CoachingPriority" "iOS coach priority model"
require_text "$IOS_MODELS" "public struct CoachingAction" "iOS coach action model"
require_text "$IOS_MODELS" "public struct CoachReview" "iOS coach review model"
require_text "$IOS_ENGINES" "public final class CoachReviewEngine" "iOS coach review engine"
require_text "$IOS_ENGINES" "lifestyle.waterLiters" "iOS coach hydration input"
require_text "$IOS_ENGINES" "lifestyle.steps" "iOS coach step input"
require_text "$IOS_ENGINES" "lifestyle.sleepHours" "iOS coach sleep input"
require_text "$IOS_ENGINES" "lifestyle.workoutMinutes" "iOS coach workout input"
require_text "$IOS_ENGINES" "lifestyle.stressLevel" "iOS coach stress input"
require_text "$IOS_ENGINES" "healthReport.flags" "iOS coach health-safety input"
require_text "$IOS_ENGINES" "proteinCategories" "iOS coach nutrition input"
require_text "$IOS_SMOKE_TESTS" "CoachReviewEngine().buildReview" "iOS coach smoke test"
require_text "$IOS_SMOKE_TESTS" ".hydration, .activity, .recovery, .healthSafety" "iOS coach lifestyle smoke coverage"

require_text "$IOS_APP" "var coachReview: CoachReview" "iOS coach review view-model output"
require_text "$IOS_APP" "DailyLifestyleInputsPanel(model: model)" "iOS daily lifestyle panel placement"
require_text "$IOS_APP" 'Panel(title: "Daily Lifestyle Inputs")' "iOS daily lifestyle input panel"
require_text "$IOS_APP" 'Stepper("Calories burned today:' "iOS calories burned input"
require_text "$IOS_APP" 'Stepper("Water:' "iOS water input"
require_text "$IOS_APP" 'Stepper("Steps:' "iOS steps input"
require_text "$IOS_APP" 'Stepper("Sleep:' "iOS sleep input"
require_text "$IOS_APP" 'Stepper("Workout:' "iOS workout input"
require_text "$IOS_APP" 'Stepper("Stress:' "iOS stress input"
require_text "$IOS_APP" "CoachReviewPanel(review: model.coachReview)" "iOS coach review panel placement"
require_text "$IOS_APP" 'Panel(title: "Daily Coach Review")' "iOS daily coach review panel"
require_text "$IOS_APP" 'Text("Strengths")' "iOS coach strengths section"
require_text "$IOS_APP" 'Text("Next Actions")' "iOS coach next actions section"
require_text "$IOS_APP" "CoachActionRow(action: action)" "iOS coach action rendering"

require_text "$DOC_FILE" "iOS lifestyle coach parity" "iOS lifestyle coach parity documentation"
require_text "$DOC_FILE" "calories burned" "iOS burn documentation"
require_text "$DOC_FILE" "water" "iOS water documentation"
require_text "$DOC_FILE" "steps" "iOS steps documentation"
require_text "$DOC_FILE" "sleep" "iOS sleep documentation"
require_text "$DOC_FILE" "workout minutes" "iOS workout documentation"
require_text "$DOC_FILE" "stress" "iOS stress documentation"
require_text "$DOC_FILE" "Pakistani" "iOS lifestyle coach audience context"
require_text "$STORE_LISTING" "Edit daily calories burned, water, steps, sleep, workout minutes, stress, and coach review actions on Android and iOS." "Store listing iOS lifestyle coach parity copy"

echo "iOS lifestyle coach parity gate passed."
