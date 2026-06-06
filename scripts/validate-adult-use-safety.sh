#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_ENGINE="$ROOT_DIR/app/src/main/java/com/pakfit/app/domain/PakistaniRecommendationEngine.kt"
ANDROID_MODELS="$ROOT_DIR/app/src/main/java/com/pakfit/app/domain/FitnessModels.kt"
ANDROID_UI="$ROOT_DIR/app/src/main/java/com/pakfit/app/ui/PakFitApp.kt"
ANDROID_TEST="$ROOT_DIR/app/src/test/java/com/pakfit/app/domain/PakistaniRecommendationEngineTest.kt"
IOS_ENGINE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitEngines.swift"
IOS_MODELS="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitModels.swift"
IOS_APP="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PakFitScreens.swift"
IOS_TEST="$ROOT_DIR/ios/PakFitIOS/Tests/PakFitCoreTests/PakFitCoreTests.swift"
IOS_SMOKE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCoreSmokeTests/main.swift"
DOC_FILE="$ROOT_DIR/docs/adult-use-safety.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"

for required_file in \
  "$ANDROID_ENGINE" \
  "$ANDROID_MODELS" \
  "$ANDROID_UI" \
  "$ANDROID_TEST" \
  "$IOS_ENGINE" \
  "$IOS_MODELS" \
  "$IOS_APP" \
  "$IOS_TEST" \
  "$IOS_SMOKE" \
  "$DOC_FILE" \
  "$STORE_LISTING"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing adult-use safety gate input: $required_file" >&2
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

block_text() {
  local file="$1"
  local text="$2"
  local description="$3"
  if grep -Fq "$text" "$file"; then
    echo "$description is still present in $file: $text" >&2
    exit 1
  fi
}

require_text "$ANDROID_ENGINE" "profile.age < 18" "Android under-18 safety warning predicate"
require_text "$ANDROID_ENGINE" "Adult-use safety boundary" "Android adult-use safety warning title"
require_text "$ANDROID_ENGINE" "parent or guardian" "Android guardian guidance"
require_text "$ANDROID_MODELS" "val caution: MedicalCaution? = null" "Android non-chip safety warning support"
require_text "$ANDROID_UI" "valueRange = 18f..75f" "Android adult age input floor"
require_text "$ANDROID_UI" "value.coerceIn(valueRange.start, valueRange.endInclusive)" "Android slider value clamping"
block_text "$ANDROID_UI" "valueRange = 16f..75f" "Android minor age input range"
require_text "$ANDROID_TEST" "underEighteenProfileCreatesAdultUseSafetyBoundaryWarning" "Android adult-use safety test"

require_text "$IOS_ENGINE" "buildRecommendation(profile: UserProfile)" "iOS recommendation warning API"
require_text "$IOS_ENGINE" "profile.age < 18" "iOS under-18 safety warning predicate"
require_text "$IOS_ENGINE" "Adult-use safety boundary" "iOS adult-use safety warning title"
require_text "$IOS_MODELS" "public struct PlanRecommendation" "iOS plan recommendation model"
require_text "$IOS_APP" "SafetyWarningRow" "iOS safety warning UI"
require_text "$IOS_APP" "Safety Review" "iOS safety review section"
require_text "$IOS_TEST" "testUnderEighteenProfileCreatesAdultUseSafetyBoundaryWarning" "iOS adult-use safety test"
require_text "$IOS_SMOKE" "under-18 profile should create an adult-use safety warning" "iOS smoke adult-use safety assertion"

require_text "$DOC_FILE" "Pakistani adults" "Adult-use safety documentation audience"
require_text "$DOC_FILE" "18 and older" "Adult-use safety documentation age boundary"
require_text "$DOC_FILE" "parent or guardian" "Adult-use safety documentation guardian boundary"
require_text "$STORE_LISTING" "PakFit is designed for adults 18 and older." "Store listing adult-use boundary"

echo "Adult-use safety gate passed."
