#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"

if [[ ! -f "$ANDROID_BUILD_FILE" ]]; then
  echo "Missing Android build file: $ANDROID_BUILD_FILE" >&2
  exit 1
fi
if [[ ! -f "$IOS_PROJECT_FILE" ]]; then
  echo "Missing iOS project file: $IOS_PROJECT_FILE" >&2
  exit 1
fi

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

android_number_setting() {
  local key="$1"
  sed -n "s/.*$key = \\([0-9][0-9]*\\).*/\\1/p" "$ANDROID_BUILD_FILE" | head -1
}

IOS_DEPLOYMENT_TARGET="$(single_unique_value "iOS IPHONEOS_DEPLOYMENT_TARGET" "$(
  sed -n 's/.*IPHONEOS_DEPLOYMENT_TARGET = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"
IOS_SWIFT_VERSION="$(single_unique_value "iOS SWIFT_VERSION" "$(
  sed -n 's/.*SWIFT_VERSION = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"

ANDROID_COMPILE_SDK="$(android_number_setting compileSdk)"
ANDROID_TARGET_SDK="$(android_number_setting targetSdk)"
ANDROID_MIN_SDK="$(android_number_setting minSdk)"

if [[ -z "$ANDROID_COMPILE_SDK" || -z "$ANDROID_TARGET_SDK" || -z "$ANDROID_MIN_SDK" ]]; then
  echo "Could not read Android compileSdk, targetSdk, or minSdk from $ANDROID_BUILD_FILE." >&2
  exit 1
fi

if [[ "$ANDROID_COMPILE_SDK" -lt 35 ]]; then
  echo "Android compileSdk must be 35 or higher for the current Play-readiness gate. Found: $ANDROID_COMPILE_SDK" >&2
  exit 1
fi
if [[ "$ANDROID_TARGET_SDK" -lt 35 ]]; then
  echo "Android targetSdk must be 35 or higher for current Google Play new app/update submissions. Found: $ANDROID_TARGET_SDK" >&2
  exit 1
fi
if [[ "$ANDROID_MIN_SDK" -lt 26 ]]; then
  echo "Android minSdk must stay 26 or higher for the current encrypted local storage baseline. Found: $ANDROID_MIN_SDK" >&2
  exit 1
fi

ANDROID_SDK_BASE=""
for sdk_root in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk" "/opt/homebrew/share/android-commandlinetools"; do
  if [[ -n "$sdk_root" && -d "$sdk_root/platforms/android-$ANDROID_COMPILE_SDK" ]]; then
    ANDROID_SDK_BASE="$sdk_root"
    break
  fi
done
if [[ -z "$ANDROID_SDK_BASE" ]]; then
  echo "Android platform android-$ANDROID_COMPILE_SDK is not installed in ANDROID_HOME, ANDROID_SDK_ROOT, ~/Library/Android/sdk, or /opt/homebrew/share/android-commandlinetools." >&2
  exit 1
fi

if ! awk "BEGIN { exit !($IOS_DEPLOYMENT_TARGET >= 16.0) }"; then
  echo "iOS deployment target must stay 16.0 or higher for current SwiftUI/PhotosPicker workflows. Found: $IOS_DEPLOYMENT_TARGET" >&2
  exit 1
fi
if ! awk "BEGIN { exit !($IOS_SWIFT_VERSION >= 5.0) }"; then
  echo "iOS SWIFT_VERSION must stay 5.0 or higher. Found: $IOS_SWIFT_VERSION" >&2
  exit 1
fi

echo "Platform compatibility gate passed."
