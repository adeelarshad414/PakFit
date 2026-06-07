#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_MODELS="$ROOT_DIR/app/src/main/java/com/pakfit/app/domain/FitnessModels.kt"
ANDROID_ENGINE="$ROOT_DIR/app/src/main/java/com/pakfit/app/domain/PakistaniRecommendationEngine.kt"
ANDROID_TEST="$ROOT_DIR/app/src/test/java/com/pakfit/app/domain/PakistaniRecommendationEngineTest.kt"
IOS_MODELS="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitModels.swift"
IOS_ENGINE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitEngines.swift"
IOS_SMOKE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCoreSmokeTests/main.swift"
IOS_TEST="$ROOT_DIR/ios/PakFitIOS/Tests/PakFitCoreTests/PakFitCoreTests.swift"
DOC_FILE="$ROOT_DIR/docs/blood-pressure-plan-safety.md"
SPEC_FILE="$ROOT_DIR/specs/064-blood-pressure-plan-safety-gate.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"
README_FILE="$ROOT_DIR/README.md"
RELEASE_SCRIPT="$ROOT_DIR/scripts/validate-release.sh"
REPORT_SCRIPT="$ROOT_DIR/scripts/generate-release-report.sh"
WORKFLOW_FILE="$ROOT_DIR/.github/workflows/pakfit-ci.yml"

for required_file in "$ANDROID_MODELS" "$ANDROID_ENGINE" "$ANDROID_TEST" "$IOS_MODELS" "$IOS_ENGINE" "$IOS_SMOKE" "$IOS_TEST" "$DOC_FILE" "$SPEC_FILE" "$STORE_LISTING" "$README_FILE" "$RELEASE_SCRIPT" "$REPORT_SCRIPT" "$WORKFLOW_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing blood pressure plan safety gate input: $required_file" >&2
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

require_text "$ANDROID_MODELS" 'HIGH_BLOOD_PRESSURE("High blood pressure")' "Android high blood pressure medical caution"
require_text "$ANDROID_ENGINE" "hasBloodPressureCaution" "Android blood pressure plan modifier"
require_text "$ANDROID_ENGINE" "Blood pressure clinician-reviewed" "Android blood pressure workout title"
require_text "$ANDROID_ENGINE" "avoid salted lassi" "Android blood pressure Ramadan hydration boundary"
require_text "$ANDROID_ENGINE" "do not self-adjust BP medicines" "Android blood pressure medicine boundary"
require_text "$ANDROID_ENGINE" "Blood pressure safety review" "Android blood pressure plan focus"
require_text "$ANDROID_TEST" "highBloodPressureCautionAddsLowerSodiumGuidanceAndModerateMovementPlan" "Android blood pressure unit test"

require_text "$IOS_MODELS" 'case highBloodPressure = "High blood pressure"' "iOS high blood pressure medical caution"
require_text "$IOS_ENGINE" "hasBloodPressureCaution" "iOS blood pressure plan modifier"
require_text "$IOS_ENGINE" "Blood pressure clinician-reviewed" "iOS blood pressure workout title"
require_text "$IOS_ENGINE" "avoid salted lassi" "iOS blood pressure Ramadan hydration boundary"
require_text "$IOS_ENGINE" "do not self-adjust BP medicines" "iOS blood pressure medicine boundary"
require_text "$IOS_ENGINE" "Blood pressure safety review" "iOS blood pressure plan focus"
require_text "$IOS_SMOKE" ".highBloodPressure" "iOS blood pressure smoke caution"
require_text "$IOS_TEST" "testHighBloodPressureCautionAddsLowerSodiumGuidanceAndModerateMovementPlan" "iOS blood pressure XCTest"

require_text "$DOC_FILE" "AHA getting active to control high blood pressure" "Blood pressure documentation AHA activity source"
require_text "$DOC_FILE" "AHA sodium and salt guidance" "Blood pressure documentation AHA sodium source"
require_text "$DOC_FILE" "CDC sodium and health context" "Blood pressure documentation CDC sodium source"
require_text "$DOC_FILE" "NHLBI heart-healthy physical activity context" "Blood pressure documentation NHLBI activity source"
require_text "$DOC_FILE" "must not diagnose hypertension, prescribe or change medicines, promise a BP outcome, present emergency care as optional, or substitute for clinician care" "Blood pressure documentation claim boundary"
require_text "$SPEC_FILE" "Blood Pressure Plan Safety Gate" "Blood pressure spec title"
require_text "$STORE_LISTING" "Blood pressure safety mode lowers sodium guidance and switches to moderate clinician-review movement guidance on Android and iOS." "Store listing blood pressure copy"
require_text "$README_FILE" "Blood pressure safety mode" "README blood pressure feature"
require_text "$RELEASE_SCRIPT" "blood pressure plan safety gate" "release validation blood pressure gate"
require_text "$REPORT_SCRIPT" "BLOOD_PRESSURE_PLAN_SAFETY_DOC_FILE" "release report blood pressure doc variable"
require_text "$REPORT_SCRIPT" "## Blood Pressure Plan Safety" "release report blood pressure section"
require_text "$WORKFLOW_FILE" "Validate blood pressure plan safety" "CI blood pressure validation"

if grep -Eiq "you have hypertension|PakFit diagnoses hypertension|diagnoses? high blood pressure|treats? hypertension|prescribes? (BP|blood pressure|hypertension|medicine|medication)|change(s|d)? BP medicine|change(s|d)? blood pressure medicine|guarantee(s|d)? BP reduction|guarantee(s|d)? blood pressure reduction|cures? hypertension|replaces? clinician|emergency care is optional" "$ANDROID_ENGINE" "$IOS_ENGINE" "$DOC_FILE" "$STORE_LISTING"; then
  echo "Unsafe blood pressure diagnosis, treatment, prescribing, guaranteed-outcome, emergency, or clinician-replacement claim detected." >&2
  exit 1
fi

echo "Blood pressure plan safety gate passed."
