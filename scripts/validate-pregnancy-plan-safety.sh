#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_ENGINE="$ROOT_DIR/app/src/main/java/com/pakfit/app/domain/PakistaniRecommendationEngine.kt"
ANDROID_TEST="$ROOT_DIR/app/src/test/java/com/pakfit/app/domain/PakistaniRecommendationEngineTest.kt"
IOS_ENGINE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitEngines.swift"
IOS_SMOKE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCoreSmokeTests/main.swift"
IOS_TEST="$ROOT_DIR/ios/PakFitIOS/Tests/PakFitCoreTests/PakFitCoreTests.swift"
DOC_FILE="$ROOT_DIR/docs/pregnancy-plan-safety.md"
SPEC_FILE="$ROOT_DIR/specs/063-pregnancy-plan-safety-gate.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"
README_FILE="$ROOT_DIR/README.md"
RELEASE_SCRIPT="$ROOT_DIR/scripts/validate-release.sh"
REPORT_SCRIPT="$ROOT_DIR/scripts/generate-release-report.sh"
WORKFLOW_FILE="$ROOT_DIR/.github/workflows/pakfit-ci.yml"

for required_file in "$ANDROID_ENGINE" "$ANDROID_TEST" "$IOS_ENGINE" "$IOS_SMOKE" "$IOS_TEST" "$DOC_FILE" "$SPEC_FILE" "$STORE_LISTING" "$README_FILE" "$RELEASE_SCRIPT" "$REPORT_SCRIPT" "$WORKFLOW_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing pregnancy plan safety gate input: $required_file" >&2
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

require_text "$ANDROID_ENGINE" "hasPregnancyCaution" "Android pregnancy plan modifier"
require_text "$ANDROID_ENGINE" "pause weight-loss calorie deficits" "Android pregnancy calorie-deficit boundary"
require_text "$ANDROID_ENGINE" "Pregnancy clinician-reviewed" "Android pregnancy workout title"
require_text "$ANDROID_ENGINE" "stop exercise and seek care" "Android pregnancy stop-warning movement copy"
require_text "$ANDROID_ENGINE" "Pregnancy safety review" "Android pregnancy plan focus"
require_text "$ANDROID_TEST" "pregnancyCautionRemovesFatLossDeficitAndUsesClinicianReviewedMovementPlan" "Android pregnancy unit test"
require_text "$ANDROID_TEST" "ordinaryFatLossPlan" "Android pregnancy calorie comparison"
require_text "$ANDROID_TEST" "Fat loss" "Android pregnancy title regression check"

require_text "$IOS_ENGINE" "hasPregnancyCaution" "iOS pregnancy plan modifier"
require_text "$IOS_ENGINE" "pause weight-loss calorie deficits" "iOS pregnancy calorie-deficit boundary"
require_text "$IOS_ENGINE" "Pregnancy clinician-reviewed" "iOS pregnancy workout title"
require_text "$IOS_ENGINE" "stop exercise and seek care" "iOS pregnancy stop-warning movement copy"
require_text "$IOS_ENGINE" "Pregnancy safety review" "iOS pregnancy plan focus"
require_text "$IOS_SMOKE" "pregnancyPlan.nutritionTargets.calories > ordinaryFatLossPlan.nutritionTargets.calories" "iOS pregnancy smoke calorie comparison"
require_text "$IOS_TEST" "testPregnancyCautionRemovesFatLossDeficitAndUsesClinicianReviewedMovementPlan" "iOS pregnancy XCTest"

require_text "$DOC_FILE" "ACOG exercise during pregnancy" "Pregnancy documentation ACOG exercise source"
require_text "$DOC_FILE" "ACOG healthy eating during pregnancy" "Pregnancy documentation ACOG nutrition source"
require_text "$DOC_FILE" "must avoid prescribing, diagnosis, complication-management, universal safety, guarantee, or obstetric-care replacement claims" "Pregnancy documentation prescribing boundary"
require_text "$SPEC_FILE" "Pregnancy Plan Safety Gate" "Pregnancy spec title"
require_text "$STORE_LISTING" "Pregnancy safety mode pauses weight-loss calorie deficits and switches to clinician-reviewed food and gentle movement guidance on Android and iOS." "Store listing pregnancy copy"
require_text "$README_FILE" "Pregnancy safety mode" "README pregnancy feature"
require_text "$RELEASE_SCRIPT" "pregnancy plan safety gate" "release validation pregnancy gate"
require_text "$REPORT_SCRIPT" "PREGNANCY_PLAN_SAFETY_DOC_FILE" "release report pregnancy doc variable"
require_text "$REPORT_SCRIPT" "## Pregnancy Plan Safety" "release report pregnancy section"
require_text "$WORKFLOW_FILE" "Validate pregnancy plan safety" "CI pregnancy validation"

if grep -Eiq "PakFit prescribes|prescribes? prenatal|prescribes? exercise|PakFit diagnoses pregnancy|diagnoses? pregnancy risk|manage(s|d)? pregnancy complications|replaces? obstetric|guaranteed pregnancy|safe for every pregnancy" "$ANDROID_ENGINE" "$IOS_ENGINE" "$DOC_FILE" "$STORE_LISTING"; then
  echo "Unsafe pregnancy prescribing, diagnosis, complication-management, replacement, guarantee, or universal-safety claim detected." >&2
  exit 1
fi

echo "Pregnancy plan safety gate passed."
