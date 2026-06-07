#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IOS_APP="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PakFitScreens.swift"
DOC_FILE="$ROOT_DIR/docs/ios-setup-parity.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"

for required_file in "$IOS_APP" "$DOC_FILE" "$STORE_LISTING"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing iOS setup parity gate input: $required_file" >&2
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

require_text "$IOS_APP" "SetupScreen(model: model)" "iOS Setup tab route"
require_text "$IOS_APP" "Label(\"Setup\", systemImage: \"person.crop.circle.badge.gearshape.fill\")" "iOS Setup tab item"
require_text "$IOS_APP" "struct SetupScreen: View" "iOS Setup screen"
require_text "$IOS_APP" 'Picker("Theme", selection: $model.themeMode)' "iOS Setup theme control"
require_text "$IOS_APP" 'Stepper("Age: \(model.profile.age) years"' "iOS Setup adult age stepper"
require_text "$IOS_APP" "in: 18...75" "iOS Setup adult age range"
require_text "$IOS_APP" 'Stepper("Height: \(model.profile.heightCm) cm"' "iOS Setup height control"
require_text "$IOS_APP" 'Stepper("Weight: \(model.profile.weightKg' "iOS Setup weight control"
require_text "$IOS_APP" 'Picker("Goal", selection: profileBinding(\.goal))' "iOS Setup goal control"
require_text "$IOS_APP" 'Picker("Activity", selection: profileBinding(\.activityLevel))' "iOS Setup activity control"
require_text "$IOS_APP" 'Picker("Diet", selection: profileBinding(\.dietPattern))' "iOS Setup diet control"
require_text "$IOS_APP" 'Picker("Training place", selection: profileBinding(\.trainingPlace))' "iOS Setup training place control"
require_text "$IOS_APP" "ToggleGrid(" "iOS Setup toggle grid"
require_text "$IOS_APP" "LifestyleMode.allCases" "iOS Setup lifestyle mode controls"
require_text "$IOS_APP" "MedicalCaution.allCases" "iOS Setup medical caution controls"
require_text "$IOS_APP" "model.profile = updated" "iOS Setup profile writeback"
require_text "$IOS_APP" "Under-18 profiles show a guardian and clinician review warning." "iOS Setup adult-use summary"

require_text "$DOC_FILE" "iOS Setup" "iOS setup parity documentation"
require_text "$DOC_FILE" "adult age floor" "iOS setup adult boundary documentation"
require_text "$DOC_FILE" "lifestyle modes" "iOS setup lifestyle documentation"
require_text "$DOC_FILE" "medical cautions" "iOS setup caution documentation"
require_text "$DOC_FILE" "Pakistani" "iOS setup audience context"
require_text "$STORE_LISTING" "Setup profile, goals, diet pattern, lifestyle modes, and medical cautions on Android and iOS." "Store listing iOS setup parity copy"

echo "iOS setup parity gate passed."
