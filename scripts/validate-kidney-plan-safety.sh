#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_ENGINE="$ROOT_DIR/app/src/main/java/com/pakfit/app/domain/PakistaniRecommendationEngine.kt"
ANDROID_TEST="$ROOT_DIR/app/src/test/java/com/pakfit/app/domain/PakistaniRecommendationEngineTest.kt"
IOS_ENGINE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitEngines.swift"
IOS_SMOKE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCoreSmokeTests/main.swift"
IOS_TEST="$ROOT_DIR/ios/PakFitIOS/Tests/PakFitCoreTests/PakFitCoreTests.swift"
DOC_FILE="$ROOT_DIR/docs/kidney-plan-safety.md"
SPEC_FILE="$ROOT_DIR/specs/065-kidney-plan-safety-gate.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"
README_FILE="$ROOT_DIR/README.md"
RELEASE_SCRIPT="$ROOT_DIR/scripts/validate-release.sh"
REPORT_SCRIPT="$ROOT_DIR/scripts/generate-release-report.sh"
WORKFLOW_FILE="$ROOT_DIR/.github/workflows/pakfit-ci.yml"

for required_file in "$ANDROID_ENGINE" "$ANDROID_TEST" "$IOS_ENGINE" "$IOS_SMOKE" "$IOS_TEST" "$DOC_FILE" "$SPEC_FILE" "$STORE_LISTING" "$README_FILE" "$RELEASE_SCRIPT" "$REPORT_SCRIPT" "$WORKFLOW_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing kidney plan safety gate input: $required_file" >&2
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

require_text "$ANDROID_ENGINE" "hasKidneyDiseaseCaution" "Android kidney plan modifier"
require_text "$ANDROID_ENGINE" "renalReviewProteinCap" "Android kidney protein cap"
require_text "$ANDROID_ENGINE" "Kidney clinician-reviewed" "Android kidney workout title"
require_text "$ANDROID_ENGINE" "not a prescription" "Android kidney prescription boundary"
require_text "$ANDROID_ENGINE" "avoid self-starting high-protein diets" "Android kidney high-protein boundary"
require_text "$ANDROID_ENGINE" "potassium, phosphorus" "Android kidney nutrient review copy"
require_text "$ANDROID_ENGINE" "Kidney safety review" "Android kidney plan focus"
require_text "$ANDROID_TEST" "kidneyDiseaseCautionCapsHighProteinTargetsAndUsesRenalReviewMovementPlan" "Android kidney unit test"

require_text "$IOS_ENGINE" "hasKidneyDiseaseCaution" "iOS kidney plan modifier"
require_text "$IOS_ENGINE" "renalReviewProteinCap" "iOS kidney protein cap"
require_text "$IOS_ENGINE" "Kidney clinician-reviewed" "iOS kidney workout title"
require_text "$IOS_ENGINE" "not a prescription" "iOS kidney prescription boundary"
require_text "$IOS_ENGINE" "avoid self-starting high-protein diets" "iOS kidney high-protein boundary"
require_text "$IOS_ENGINE" "potassium, phosphorus" "iOS kidney nutrient review copy"
require_text "$IOS_ENGINE" "Kidney safety review" "iOS kidney plan focus"
require_text "$IOS_SMOKE" ".kidneyDisease" "iOS kidney smoke caution"
require_text "$IOS_TEST" "testKidneyDiseaseCautionCapsHighProteinTargetsAndUsesRenalReviewMovementPlan" "iOS kidney XCTest"

require_text "$DOC_FILE" "NIDDK healthy eating for adults with CKD" "Kidney documentation NIDDK CKD source"
require_text "$DOC_FILE" "NIDDK eating right with kidney failure" "Kidney documentation kidney failure source"
require_text "$DOC_FILE" "CDC living with chronic kidney disease" "Kidney documentation CDC source"
require_text "$DOC_FILE" "National Kidney Foundation nutrition and kidney disease stages 1-5" "Kidney documentation NKF source"
require_text "$DOC_FILE" "must not diagnose kidney disease, prescribe protein, prescribe sodium/potassium/phosphorus/fluid limits, recommend supplements, claim to improve kidney function, present dialysis-stage guidance as universal, or substitute for clinician care" "Kidney documentation claim boundary"
require_text "$SPEC_FILE" "Kidney Plan Safety Gate" "Kidney spec title"
require_text "$STORE_LISTING" "Kidney safety mode caps high-protein targets and switches to renal clinician-review nutrition and movement guidance on Android and iOS." "Store listing kidney copy"
require_text "$README_FILE" "Kidney safety mode" "README kidney feature"
require_text "$RELEASE_SCRIPT" "kidney plan safety gate" "release validation kidney gate"
require_text "$REPORT_SCRIPT" "KIDNEY_PLAN_SAFETY_DOC_FILE" "release report kidney doc variable"
require_text "$REPORT_SCRIPT" "## Kidney Plan Safety" "release report kidney section"
require_text "$WORKFLOW_FILE" "Validate kidney plan safety" "CI kidney validation"

if grep -Eiq "you have kidney disease|PakFit diagnoses kidney|diagnosed with kidney disease|PakFit treats? kidney disease|PakFit prescribes? (protein|sodium|potassium|phosphorus|fluid|renal|kidney)|app prescribes? (protein|sodium|potassium|phosphorus|fluid|renal|kidney)|recommend(s|ed)? (creatine|detox|herbal kidney cure|supplement stack)|will improve kidney function|improves kidney function|improve your kidney function|cures? kidney|replaces? (doctor|clinician|renal dietitian)|safe for every kidney|universal dialysis" "$ANDROID_ENGINE" "$IOS_ENGINE" "$DOC_FILE" "$STORE_LISTING"; then
  echo "Unsafe kidney diagnosis, treatment, prescribing, supplement, outcome, universal dialysis, or clinician-replacement claim detected." >&2
  exit 1
fi

echo "Kidney plan safety gate passed."
