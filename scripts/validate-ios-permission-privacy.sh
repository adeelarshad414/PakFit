#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"
IOS_APP_SWIFT_DIR="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp"
IOS_CORE_SWIFT_DIR="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore"

for required_path in "$IOS_PROJECT_FILE" "$IOS_APP_SWIFT_DIR" "$IOS_CORE_SWIFT_DIR"; do
  if [[ ! -e "$required_path" ]]; then
    echo "Missing iOS permission privacy input: $required_path" >&2
    exit 1
  fi
done

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep not found; install rg to run the iOS permission privacy gate." >&2
  exit 1
fi

usage_values() {
  local key="$1"
  sed -n "s/.*$key = \"\\([^\"]*\\)\";.*/\\1/p" "$IOS_PROJECT_FILE"
}

validate_food_photo_usage_string() {
  local key="$1"
  local count
  count="$(usage_values "$key" | sed '/^$/d' | wc -l | tr -d ' ')"
  if [[ "$count" -lt 2 ]]; then
    echo "iOS permission privacy gate failed: $key must be present in Debug and Release build settings." >&2
    exit 1
  fi

  while IFS= read -r value; do
    if [[ -z "$value" ]]; then
      continue
    fi
    case "$value" in
      *PakFit*food\ photo*visible\ calories*) ;;
      *)
        echo "iOS permission privacy gate failed: $key must stay product-specific and food-photo scoped." >&2
        echo "Found: $value" >&2
        exit 1
        ;;
    esac
  done < <(usage_values "$key")
}

validate_food_photo_usage_string "INFOPLIST_KEY_NSCameraUsageDescription"
validate_food_photo_usage_string "INFOPLIST_KEY_NSPhotoLibraryUsageDescription"

if rg -n 'INFOPLIST_KEY_NS[A-Za-z0-9]+UsageDescription' "$IOS_PROJECT_FILE" \
  | grep -Ev 'INFOPLIST_KEY_(NSCameraUsageDescription|NSPhotoLibraryUsageDescription)'; then
  echo "iOS permission privacy gate failed: unexpected iOS usage-description key requires a reviewed privacy spec." >&2
  exit 1
fi

UNREVIEWED_PERMISSION_API_PATTERN='AVCapture|AVAudio|CLLocation|CNContact|HKHealthStore|MPMediaLibrary|CBCentralManager|CBPeripheralManager|SFSpeechRecognizer|NFCNDEFReaderSession|PHPhotoLibrary\.requestAuthorization|requestWhenInUseAuthorization|requestAlwaysAuthorization|requestRecordPermission|requestAccess'
if rg -n "$UNREVIEWED_PERMISSION_API_PATTERN" "$IOS_APP_SWIFT_DIR" "$IOS_CORE_SWIFT_DIR"; then
  echo "iOS permission privacy gate failed: unreviewed permission-sensitive API usage was detected." >&2
  exit 1
fi

if ! rg -q 'PhotosPicker' "$IOS_APP_SWIFT_DIR"; then
  echo "iOS food photo workflow must keep an explicit photo picker control visible in app source." >&2
  exit 1
fi

if ! rg -q 'UIImagePickerController' "$IOS_APP_SWIFT_DIR"; then
  echo "iOS food photo workflow must keep an explicit camera capture control visible in app source." >&2
  exit 1
fi

echo "iOS permission privacy gate passed."
