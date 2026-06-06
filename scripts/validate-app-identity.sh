#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
ANDROID_MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
ANDROID_STRINGS="$ROOT_DIR/app/src/main/res/values/strings.xml"
IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"

for required_file in "$ANDROID_BUILD_FILE" "$ANDROID_MANIFEST" "$ANDROID_STRINGS" "$IOS_PROJECT_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing app identity input: $required_file" >&2
    exit 1
  fi
done

single_unique_value() {
  local label="$1"
  local values="$2"
  local unique
  unique="$(printf '%s\n' "$values" | sed '/^$/d' | sort -u)"
  local count
  count="$(printf '%s\n' "$unique" | sed '/^$/d' | wc -l | tr -d ' ')"
  if [[ "$count" != "1" ]]; then
    echo "$label must have exactly one unique value. Found:" >&2
    printf '%s\n' "$unique" >&2
    exit 1
  fi
  printf '%s\n' "$unique"
}

ANDROID_NAMESPACE="$(single_unique_value "Android namespace" "$(
  sed -n 's/.*namespace = "\([^"]*\)".*/\1/p' "$ANDROID_BUILD_FILE"
)")"
ANDROID_APPLICATION_ID="$(single_unique_value "Android applicationId" "$(
  sed -n 's/.*applicationId = "\([^"]*\)".*/\1/p' "$ANDROID_BUILD_FILE"
)")"
ANDROID_APP_NAME="$(single_unique_value "Android app_name" "$(
  sed -n 's/.*<string name="app_name">\([^<]*\)<\/string>.*/\1/p' "$ANDROID_STRINGS"
)")"
IOS_BUNDLE_ID="$(single_unique_value "iOS PRODUCT_BUNDLE_IDENTIFIER" "$(
  sed -n 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"
IOS_DISPLAY_NAME="$(single_unique_value "iOS CFBundleDisplayName" "$(
  sed -n 's/.*INFOPLIST_KEY_CFBundleDisplayName = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"
IOS_TARGETED_DEVICE_FAMILY="$(single_unique_value "iOS TARGETED_DEVICE_FAMILY" "$(
  sed -n 's/.*TARGETED_DEVICE_FAMILY = "\([^"]*\)";.*/\1/p' "$IOS_PROJECT_FILE"
)")"
IOS_SUPPORTED_PLATFORMS="$(single_unique_value "iOS SUPPORTED_PLATFORMS" "$(
  sed -n 's/.*SUPPORTED_PLATFORMS = "\([^"]*\)";.*/\1/p' "$IOS_PROJECT_FILE"
)")"
IOS_MACCATALYST_SUPPORT="$(single_unique_value "iOS SUPPORTS_MACCATALYST" "$(
  sed -n 's/.*SUPPORTS_MACCATALYST = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"

if [[ "$ANDROID_NAMESPACE" != "com.pakfit.app" ]]; then
  echo "Android namespace must remain com.pakfit.app for this release channel. Found: $ANDROID_NAMESPACE" >&2
  exit 1
fi
if [[ "$ANDROID_APPLICATION_ID" != "com.pakfit.app" ]]; then
  echo "Android applicationId must remain com.pakfit.app for this release channel. Found: $ANDROID_APPLICATION_ID" >&2
  exit 1
fi
if [[ "$ANDROID_APP_NAME" != "PakFit" ]]; then
  echo "Android app_name must remain PakFit. Found: $ANDROID_APP_NAME" >&2
  exit 1
fi
if ! grep -q 'android:label="@string/app_name"' "$ANDROID_MANIFEST"; then
  echo "Android manifest must use @string/app_name as the application label." >&2
  exit 1
fi
if ! grep -q 'android:theme="@style/Theme.PakFit"' "$ANDROID_MANIFEST"; then
  echo "Android manifest must use the PakFit app theme." >&2
  exit 1
fi

if [[ "$IOS_BUNDLE_ID" != "com.pakfit.ios" ]]; then
  echo "iOS bundle identifier must remain com.pakfit.ios for this release channel. Found: $IOS_BUNDLE_ID" >&2
  exit 1
fi
if [[ "$IOS_DISPLAY_NAME" != "PakFit" ]]; then
  echo "iOS display name must remain PakFit. Found: $IOS_DISPLAY_NAME" >&2
  exit 1
fi
if [[ "$IOS_TARGETED_DEVICE_FAMILY" != "1,2" ]]; then
  echo "iOS target device family must include iPhone and iPad. Found: $IOS_TARGETED_DEVICE_FAMILY" >&2
  exit 1
fi
if [[ "$IOS_SUPPORTED_PLATFORMS" != "iphoneos iphonesimulator" ]]; then
  echo "iOS supported platforms must stay iPhone device/simulator scoped. Found: $IOS_SUPPORTED_PLATFORMS" >&2
  exit 1
fi
if [[ "$IOS_MACCATALYST_SUPPORT" != "NO" ]]; then
  echo "Mac Catalyst must remain disabled until a reviewed desktop UI/spec exists. Found: $IOS_MACCATALYST_SUPPORT" >&2
  exit 1
fi

echo "App identity gate passed."
