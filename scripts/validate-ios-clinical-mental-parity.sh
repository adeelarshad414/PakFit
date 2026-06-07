#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IOS_APP="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PakFitScreens.swift"
IOS_SNAPSHOT="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitSnapshot.swift"
IOS_ENGINES="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitEngines.swift"
IOS_SMOKE_TESTS="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCoreSmokeTests/main.swift"
DOC_FILE="$ROOT_DIR/docs/ios-clinical-mental-parity.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"

for required_file in "$IOS_APP" "$IOS_SNAPSHOT" "$IOS_ENGINES" "$IOS_SMOKE_TESTS" "$DOC_FILE" "$STORE_LISTING"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing iOS clinical/mental parity gate input: $required_file" >&2
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

require_text "$IOS_SNAPSHOT" "public enum MentalScale" "iOS mental scale model"
require_text "$IOS_SNAPSHOT" "public enum MentalSeverity" "iOS mental severity model"
require_text "$IOS_SNAPSHOT" "public struct MentalWellnessReport" "iOS mental wellness report model"
require_text "$IOS_SNAPSHOT" "public struct CrisisResource" "iOS crisis resource model"
require_text "$IOS_SNAPSHOT" "public enum ClinicalRiskType" "iOS clinical risk type model"
require_text "$IOS_SNAPSHOT" "public enum ClinicalRiskLevel" "iOS clinical risk level model"
require_text "$IOS_SNAPSHOT" "public struct ClinicalRiskInsight" "iOS clinical risk insight model"
require_text "$IOS_SNAPSHOT" "public struct ClinicalIntelligenceReport" "iOS clinical report model"
require_text "$IOS_ENGINES" "public final class MentalWellnessEngine" "iOS mental wellness engine"
require_text "$IOS_ENGINES" "public final class ClinicalIntelligenceEngine" "iOS clinical intelligence engine"
require_text "$IOS_ENGINES" "Rescue 1122" "iOS Pakistan crisis resource"
require_text "$IOS_ENGINES" "Umang Pakistan" "iOS Pakistan mental health resource"
require_text "$IOS_ENGINES" "diabetesInsight" "iOS diabetes insight"
require_text "$IOS_ENGINES" "hypertensionInsight" "iOS hypertension insight"
require_text "$IOS_ENGINES" "cardiovascularInsight" "iOS cardiovascular insight"
require_text "$IOS_ENGINES" "vitaminDInsight" "iOS vitamin D insight"
require_text "$IOS_ENGINES" "ironAnemiaInsight" "iOS anemia insight"
require_text "$IOS_SMOKE_TESTS" "ClinicalIntelligenceEngine().buildReport" "iOS clinical smoke test"
require_text "$IOS_SMOKE_TESTS" "MentalWellnessEngine().buildReport" "iOS mental smoke test"
require_text "$IOS_SMOKE_TESTS" "Rescue 1122" "iOS crisis resource smoke test"

require_text "$IOS_APP" "private let clinicalEngine = ClinicalIntelligenceEngine()" "iOS clinical engine wiring"
require_text "$IOS_APP" "private let mentalWellnessEngine = MentalWellnessEngine()" "iOS mental engine wiring"
require_text "$IOS_APP" "var clinicalReport: ClinicalIntelligenceReport" "iOS clinical report view-model output"
require_text "$IOS_APP" "var mentalWellnessReport: MentalWellnessReport" "iOS mental report view-model output"
require_text "$IOS_APP" "ClinicalRiskInputPanel(" "iOS clinical risk input placement"
require_text "$IOS_APP" "ClinicalInsightsPanel(report: model.clinicalReport)" "iOS clinical insights placement"
require_text "$IOS_APP" "MentalWellnessPanel(" "iOS mental wellness panel placement"
require_text "$IOS_APP" 'Panel(title: "Clinical Risk Factors")' "iOS clinical risk input panel"
require_text "$IOS_APP" 'Panel(title: "Clinical Insights")' "iOS clinical insights panel"
require_text "$IOS_APP" 'Panel(title: "Mental Wellness")' "iOS mental wellness panel"
require_text "$IOS_APP" 'Stepper("PHQ-9 score:' "iOS PHQ-9 control"
require_text "$IOS_APP" 'Stepper("GAD-7 score:' "iOS GAD-7 control"
require_text "$IOS_APP" "MentalSupportFlag.allCases" "iOS mental support flags"
require_text "$IOS_APP" "CrisisResourceRow(resource: resource)" "iOS crisis resource rendering"
require_text "$IOS_APP" "ClinicalRiskInsightRow(insight: insight)" "iOS clinical insight rendering"

require_text "$DOC_FILE" "iOS clinical and mental wellness parity" "iOS clinical mental parity documentation"
require_text "$DOC_FILE" "PHQ-9" "iOS PHQ-9 documentation"
require_text "$DOC_FILE" "GAD-7" "iOS GAD-7 documentation"
require_text "$DOC_FILE" "crisis support" "iOS crisis support documentation"
require_text "$DOC_FILE" "diabetes risk" "iOS diabetes risk documentation"
require_text "$DOC_FILE" "BP risk" "iOS BP risk documentation"
require_text "$DOC_FILE" "heart risk" "iOS heart risk documentation"
require_text "$DOC_FILE" "vitamin D risk" "iOS vitamin D documentation"
require_text "$DOC_FILE" "anemia risk" "iOS anemia documentation"
require_text "$DOC_FILE" "Pakistani" "iOS clinical mental audience context"
require_text "$STORE_LISTING" "Review PHQ-9, GAD-7, crisis support, diabetes risk, BP risk, heart risk, vitamin D risk, and anemia risk on Android and iOS." "Store listing iOS clinical mental parity copy"

echo "iOS clinical and mental wellness parity gate passed."
