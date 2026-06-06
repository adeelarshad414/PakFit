#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_UI="$ROOT_DIR/app/src/main/java/com/pakfit/app/ui/PakFitApp.kt"
IOS_UI="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PakFitScreens.swift"
DOC_FILE="$ROOT_DIR/docs/accessibility-readability.md"

for required_file in "$ANDROID_UI" "$IOS_UI" "$DOC_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing accessibility/readability gate input: $required_file" >&2
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

require_absent_regex() {
  local file="$1"
  local pattern="$2"
  local description="$3"
  if grep -En "$pattern" "$file"; then
    echo "$description detected in $file." >&2
    exit 1
  fi
}

require_text "$ANDROID_UI" "Modifier.semantics { heading() }" "Android Compose heading semantics"
require_text "$ANDROID_UI" "semantics(mergeDescendants = true)" "Android combined semantic labels"
require_text "$ANDROID_UI" "ProgressBarRangeInfo" "Android custom progress range semantics"
require_text "$ANDROID_UI" "progressBarRangeInfo = ProgressBarRangeInfo" "Android progress bar semantic range"
require_text "$ANDROID_UI" "contentDescription = \"Captured food photo\"" "Android food-photo image description"
require_text "$ANDROID_UI" "accessibilityLabel: String" "Android custom progress accessibility label"
require_absent_regex "$ANDROID_UI" "contentDescription\\s*=\\s*\"\"" "Empty Android content descriptions"

if grep -q "Image(" "$ANDROID_UI"; then
  local_image_count="$(grep -c "Image(" "$ANDROID_UI" | tr -d ' ')"
  local_description_count="$(grep -c "contentDescription =" "$ANDROID_UI" | tr -d ' ')"
  if [[ "$local_description_count" -lt "$local_image_count" ]]; then
    echo "Every Android Image use must include a contentDescription." >&2
    exit 1
  fi
fi

require_text "$IOS_UI" ".font(.largeTitle.weight(.bold))" "iOS Dynamic Type BMI font"
require_text "$IOS_UI" ".font(.title.weight(.bold))" "iOS Dynamic Type target font"
require_text "$IOS_UI" ".accessibilityElement(children: .combine)" "iOS combined accessibility elements"
require_text "$IOS_UI" ".accessibilityElement(children: .ignore)" "iOS custom chart accessibility elements"
require_text "$IOS_UI" ".accessibilityHidden(true)" "iOS decorative icon hiding"
require_text "$IOS_UI" ".accessibilityLabel(" "iOS accessibility labels"
require_absent_regex "$IOS_UI" "\\.font\\(\\.system\\(size:" "Fixed-size SwiftUI fonts"

require_text "$DOC_FILE" "Dynamic Type" "Accessibility documentation Dynamic Type boundary"
require_text "$DOC_FILE" "custom charts" "Accessibility documentation chart boundary"
require_text "$DOC_FILE" "screen readers" "Accessibility documentation assistive technology boundary"
require_text "$DOC_FILE" "Pakistani" "Accessibility documentation audience context"

echo "Accessibility and readability gate passed."
