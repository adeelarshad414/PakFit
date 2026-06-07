#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_ENGINE="$ROOT_DIR/app/src/main/java/com/pakfit/app/domain/PakistaniRecommendationEngine.kt"
ANDROID_TEST="$ROOT_DIR/app/src/test/java/com/pakfit/app/domain/PakistaniRecommendationEngineTest.kt"
IOS_ENGINE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitEngines.swift"
IOS_SMOKE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCoreSmokeTests/main.swift"
IOS_TEST="$ROOT_DIR/ios/PakFitIOS/Tests/PakFitCoreTests/PakFitCoreTests.swift"
DOC_FILE="$ROOT_DIR/docs/diabetes-medication-plan-safety.md"
SPEC_FILE="$ROOT_DIR/specs/066-diabetes-medication-plan-safety-gate.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"
README_FILE="$ROOT_DIR/README.md"
RELEASE_SCRIPT="$ROOT_DIR/scripts/validate-release.sh"
REPORT_SCRIPT="$ROOT_DIR/scripts/generate-release-report.sh"
WORKFLOW_FILE="$ROOT_DIR/.github/workflows/pakfit-ci.yml"

for required_file in "$ANDROID_ENGINE" "$ANDROID_TEST" "$IOS_ENGINE" "$IOS_SMOKE" "$IOS_TEST" "$DOC_FILE" "$SPEC_FILE" "$STORE_LISTING" "$README_FILE" "$RELEASE_SCRIPT" "$REPORT_SCRIPT" "$WORKFLOW_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing diabetes medication plan safety gate input: $required_file" >&2
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

require_text "$ANDROID_ENGINE" "hasDiabetesMedicationCaution" "Android diabetes medication plan modifier"
require_text "$ANDROID_ENGINE" "Diabetes medication clinician-reviewed" "Android diabetes medication workout title"
require_text "$ANDROID_ENGINE" "pauses aggressive calorie deficits or surpluses" "Android diabetes medication calorie-boundary copy"
require_text "$ANDROID_ENGINE" "consistent carbohydrate portions" "Android diabetes medication carbohydrate consistency copy"
require_text "$ANDROID_ENGINE" "do not self-adjust diabetes medicines" "Android diabetes medication medicine boundary"
require_text "$ANDROID_ENGINE" "low-glucose symptoms" "Android diabetes medication low-glucose copy"
require_text "$ANDROID_ENGINE" "avoid hard fasted training" "Android diabetes medication Ramadan training boundary"
require_text "$ANDROID_ENGINE" "Diabetes medication safety review" "Android diabetes medication plan focus"
require_text "$ANDROID_TEST" "diabetesMedicationCautionPausesAggressiveTargetsAndUsesClinicianReviewedMovementPlan" "Android diabetes medication unit test"

require_text "$IOS_ENGINE" "hasDiabetesMedicationCaution" "iOS diabetes medication plan modifier"
require_text "$IOS_ENGINE" "Diabetes medication clinician-reviewed" "iOS diabetes medication workout title"
require_text "$IOS_ENGINE" "pauses aggressive calorie deficits or surpluses" "iOS diabetes medication calorie-boundary copy"
require_text "$IOS_ENGINE" "consistent carbohydrate portions" "iOS diabetes medication carbohydrate consistency copy"
require_text "$IOS_ENGINE" "do not self-adjust diabetes medicines" "iOS diabetes medication medicine boundary"
require_text "$IOS_ENGINE" "low-glucose symptoms" "iOS diabetes medication low-glucose copy"
require_text "$IOS_ENGINE" "avoid hard fasted training" "iOS diabetes medication Ramadan training boundary"
require_text "$IOS_ENGINE" "Diabetes medication safety review" "iOS diabetes medication plan focus"
require_text "$IOS_SMOKE" ".diabetesMedication" "iOS diabetes medication smoke caution"
require_text "$IOS_TEST" "testDiabetesMedicationCautionPausesAggressiveTargetsAndUsesClinicianReviewedMovementPlan" "iOS diabetes medication XCTest"

require_text "$DOC_FILE" "ADA blood glucose and exercise guidance" "Diabetes medication documentation ADA exercise source"
require_text "$DOC_FILE" "ADA hypoglycemia symptoms and 15-15 rule" "Diabetes medication documentation ADA hypoglycemia source"
require_text "$DOC_FILE" "CDC low blood sugar hypoglycemia guidance" "Diabetes medication documentation CDC hypoglycemia source"
require_text "$DOC_FILE" "CDC diabetes physical activity guidance" "Diabetes medication documentation CDC physical activity source"
require_text "$DOC_FILE" "IDF-DAR Ramadan diabetes fasting guidance" "Diabetes medication documentation IDF-DAR source"
require_text "$DOC_FILE" "must not diagnose diabetes, treat diabetes, prescribe insulin, prescribe oral diabetes medicines, adjust medicine doses, provide personal glucose targets, guarantee fasting safety, claim to prevent hypoglycemia, claim to reverse diabetes, replace a diabetes educator, replace a dietitian, replace a pharmacist, or replace doctor care" "Diabetes medication documentation claim boundary"
require_text "$SPEC_FILE" "Diabetes Medication Plan Safety Gate" "Diabetes medication spec title"
require_text "$STORE_LISTING" "Diabetes medication safety mode pauses aggressive calorie targets and switches to clinician-reviewed meal timing and moderate movement guidance on Android and iOS." "Store listing diabetes medication copy"
require_text "$README_FILE" "Diabetes medication safety mode" "README diabetes medication feature"
require_text "$RELEASE_SCRIPT" "diabetes medication plan safety gate" "release validation diabetes medication gate"
require_text "$REPORT_SCRIPT" "DIABETES_MEDICATION_PLAN_SAFETY_DOC_FILE" "release report diabetes medication doc variable"
require_text "$REPORT_SCRIPT" "## Diabetes Medication Plan Safety" "release report diabetes medication section"
require_text "$WORKFLOW_FILE" "Validate diabetes medication plan safety" "CI diabetes medication validation"

if grep -Eiq "(PakFit|app) (diagnoses|treats|prescribes|adjusts|reverses) diabetes|will prevent hypoglycemia|guaranteed fasting safety|safe for every fast|safe to fast without clinician|insulin dose of|medicine dose of|oral medicine dose of" "$ANDROID_ENGINE" "$IOS_ENGINE" "$DOC_FILE" "$STORE_LISTING"; then
  echo "Unsafe diabetes diagnosis, treatment, prescribing, medicine-adjustment, reversal, guaranteed fasting, or hypoglycemia-prevention claim detected." >&2
  exit 1
fi

echo "Diabetes medication plan safety gate passed."
