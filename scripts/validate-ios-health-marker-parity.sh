#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IOS_APP="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PakFitScreens.swift"
DOC_FILE="$ROOT_DIR/docs/ios-health-marker-parity.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"

for required_file in "$IOS_APP" "$DOC_FILE" "$STORE_LISTING"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing iOS health marker parity gate input: $required_file" >&2
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

require_text "$IOS_APP" 'Panel(title: "Health Marker Inputs")' "iOS Health marker input panel"
require_text "$IOS_APP" 'Picker("Diabetes status", selection: diabetesStatusBinding)' "iOS diabetes status input"
require_text "$IOS_APP" 'Stepper("Total cholesterol:' "iOS total cholesterol input"
require_text "$IOS_APP" 'Stepper("LDL:' "iOS LDL input"
require_text "$IOS_APP" 'Stepper("HDL:' "iOS HDL input"
require_text "$IOS_APP" 'Stepper("Triglycerides:' "iOS triglycerides input"
require_text "$IOS_APP" 'Stepper("Uric acid:' "iOS uric acid input"
require_text "$IOS_APP" 'Stepper("Fasting blood sugar:' "iOS fasting blood sugar input"
require_text "$IOS_APP" 'Stepper("Systolic BP:' "iOS systolic BP input"
require_text "$IOS_APP" 'Stepper("Diastolic BP:' "iOS diastolic BP input"
require_text "$IOS_APP" 'Stepper("HbA1c:' "iOS HbA1c input"
require_text "$IOS_APP" 'Stepper("Hemoglobin:' "iOS hemoglobin input"
require_text "$IOS_APP" 'Toggle("Chest pain or severe symptoms", isOn: chestPainBinding)' "iOS emergency symptom input"
require_text "$IOS_APP" "private var diabetesStatusBinding" "iOS diabetes status writeback"
require_text "$IOS_APP" "private var chestPainBinding" "iOS chest pain writeback"
require_text "$IOS_APP" "private func labIntBinding" "iOS integer marker writeback"
require_text "$IOS_APP" "private func labDoubleBinding" "iOS decimal marker writeback"
require_text "$IOS_APP" "model.labProfile = updated" "iOS lab profile state writeback"

require_text "$DOC_FILE" "iOS Health marker" "iOS health marker parity documentation"
require_text "$DOC_FILE" "lipid profile" "iOS health marker lipid documentation"
require_text "$DOC_FILE" "uric acid" "iOS health marker uric acid documentation"
require_text "$DOC_FILE" "fasting blood sugar" "iOS health marker glucose documentation"
require_text "$DOC_FILE" "HbA1c" "iOS health marker HbA1c documentation"
require_text "$DOC_FILE" "hemoglobin" "iOS health marker hemoglobin documentation"
require_text "$DOC_FILE" "Pakistani" "iOS health marker audience context"
require_text "$STORE_LISTING" "Edit BMI inputs, blood pressure, lipid profile, uric acid, blood sugar, HbA1c, hemoglobin, and diabetes status on Android and iOS." "Store listing iOS health marker parity copy"

echo "iOS health marker parity gate passed."
