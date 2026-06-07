#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_CLINICAL="$ROOT_DIR/app/src/main/java/com/pakfit/app/domain/ClinicalIntelligenceModels.kt"
ANDROID_TEST="$ROOT_DIR/app/src/test/java/com/pakfit/app/domain/ClinicalIntelligenceEngineTest.kt"
ANDROID_UI="$ROOT_DIR/app/src/main/java/com/pakfit/app/ui/PakFitApp.kt"
IOS_SNAPSHOT="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitSnapshot.swift"
IOS_ENGINE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitEngines.swift"
IOS_SMOKE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCoreSmokeTests/main.swift"
IOS_UI="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PakFitScreens.swift"
DOC_FILE="$ROOT_DIR/docs/pcos-clinical-safety.md"
SPEC_FILE="$ROOT_DIR/specs/062-pcos-clinical-safety-gate.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"
README_FILE="$ROOT_DIR/README.md"
RELEASE_SCRIPT="$ROOT_DIR/scripts/validate-release.sh"
REPORT_SCRIPT="$ROOT_DIR/scripts/generate-release-report.sh"
WORKFLOW_FILE="$ROOT_DIR/.github/workflows/pakfit-ci.yml"

for required_file in "$ANDROID_CLINICAL" "$ANDROID_TEST" "$ANDROID_UI" "$IOS_SNAPSHOT" "$IOS_ENGINE" "$IOS_SMOKE" "$IOS_UI" "$DOC_FILE" "$SPEC_FILE" "$STORE_LISTING" "$README_FILE" "$RELEASE_SCRIPT" "$REPORT_SCRIPT" "$WORKFLOW_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing PCOS clinical safety gate input: $required_file" >&2
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

require_text "$ANDROID_CLINICAL" 'IRREGULAR_OR_MISSED_PERIODS("Irregular or missed periods")' "Android PCOS cycle risk factor"
require_text "$ANDROID_CLINICAL" 'EXCESS_HAIR_OR_PERSISTENT_ACNE("Excess hair or persistent acne")' "Android PCOS androgen-sign risk factor"
require_text "$ANDROID_CLINICAL" 'KNOWN_PCOS("Known PCOS")' "Android known PCOS risk factor"
require_text "$ANDROID_CLINICAL" 'PCOS_METABOLIC_REPRODUCTIVE("PCOS metabolic and reproductive")' "Android PCOS risk type"
require_text "$ANDROID_CLINICAL" "pcosInsight" "Android PCOS insight engine"
require_text "$ANDROID_CLINICAL" "NICHD PCOS symptom guidance and CDC PCOS diabetes risk guidance" "Android official PCOS source category"
require_text "$ANDROID_CLINICAL" "Do not self-start hormones, metformin, fertility medicines, or supplements" "Android PCOS medication boundary"
require_text "$ANDROID_CLINICAL" "does not diagnose PCOS" "Android PCOS diagnosis boundary"
require_text "$ANDROID_TEST" "pcosScreeningUsesCycleAndAndrogenSignsWithoutDiagnosisOrMedicineAdvice" "Android PCOS unit test"
require_text "$ANDROID_TEST" "ClinicalRiskType.PCOS_METABOLIC_REPRODUCTIVE" "Android PCOS test risk type"
require_text "$ANDROID_UI" "PCOS review signs" "Android PCOS clinical UI copy"

require_text "$IOS_SNAPSHOT" 'case irregularOrMissedPeriods = "Irregular or missed periods"' "iOS PCOS cycle risk factor"
require_text "$IOS_SNAPSHOT" 'case excessHairOrPersistentAcne = "Excess hair or persistent acne"' "iOS PCOS androgen-sign risk factor"
require_text "$IOS_SNAPSHOT" 'case knownPcos = "Known PCOS"' "iOS known PCOS risk factor"
require_text "$IOS_SNAPSHOT" 'case pcosMetabolicReproductive = "PCOS metabolic and reproductive"' "iOS PCOS risk type"
require_text "$IOS_ENGINE" "pcosInsight" "iOS PCOS insight engine"
require_text "$IOS_ENGINE" "NICHD PCOS symptom guidance and CDC PCOS diabetes risk guidance" "iOS official PCOS source category"
require_text "$IOS_ENGINE" "Do not self-start hormones, metformin, fertility medicines, or supplements" "iOS PCOS medication boundary"
require_text "$IOS_ENGINE" "does not diagnose PCOS" "iOS PCOS diagnosis boundary"
require_text "$IOS_SMOKE" ".pcosMetabolicReproductive" "iOS PCOS smoke test"
require_text "$IOS_SMOKE" ".irregularOrMissedPeriods, .excessHairOrPersistentAcne" "iOS PCOS smoke risk factors"
require_text "$IOS_UI" "PCOS review signs" "iOS PCOS clinical UI copy"
require_text "$IOS_UI" "pcosMetabolicReproductive" "iOS PCOS icon routing"

require_text "$DOC_FILE" "NICHD PCOS symptom guidance" "PCOS documentation NICHD source"
require_text "$DOC_FILE" "CDC PCOS and diabetes risk guidance" "PCOS documentation CDC source"
require_text "$DOC_FILE" "must not make diagnosis, treatment, prescribing, fertility-outcome, cure, or clinician-replacement claims" "PCOS documentation diagnosis boundary"
require_text "$SPEC_FILE" "PCOS Clinical Safety Gate" "PCOS spec title"
require_text "$STORE_LISTING" "Review PCOS metabolic and reproductive screening signs on Android and iOS with non-diagnostic clinician-review guidance." "Store listing PCOS copy"
require_text "$README_FILE" "PCOS metabolic/reproductive screening" "README PCOS feature"
require_text "$RELEASE_SCRIPT" "PCOS clinical safety gate" "release validation PCOS gate"
require_text "$REPORT_SCRIPT" "PCOS_CLINICAL_SAFETY_DOC_FILE" "release report PCOS doc variable"
require_text "$REPORT_SCRIPT" "## PCOS Clinical Safety" "release report PCOS section"
require_text "$WORKFLOW_FILE" "Validate PCOS clinical safety" "CI PCOS validation"

if grep -Eiq "you have PCOS|PakFit diagnoses PCOS|diagnosed with PCOS|treats? PCOS|prescribes? (PCOS|hormones|metformin|fertility|medicine)|improves fertility|cures PCOS|reverse(s|d)? PCOS" "$ANDROID_CLINICAL" "$IOS_ENGINE" "$DOC_FILE" "$STORE_LISTING"; then
  echo "Unsafe PCOS diagnosis, treatment, fertility, cure, or prescribing claim detected." >&2
  exit 1
fi

echo "PCOS clinical safety gate passed."
