#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

INCLUDE_BUILT_METADATA=false
if [[ "${1:-}" == "--include-built-metadata" ]]; then
  INCLUDE_BUILT_METADATA=true
fi

ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"
DEBUG_METADATA_FILE="$ROOT_DIR/app/build/outputs/apk/debug/output-metadata.json"
RELEASE_METADATA_FILE="$ROOT_DIR/app/build/outputs/apk/release/output-metadata.json"

if [[ ! -f "$ANDROID_BUILD_FILE" ]]; then
  echo "Missing Android build file: $ANDROID_BUILD_FILE" >&2
  exit 1
fi
if [[ ! -f "$IOS_PROJECT_FILE" ]]; then
  echo "Missing iOS project file: $IOS_PROJECT_FILE" >&2
  exit 1
fi

single_unique_value() {
  local description="$1"
  local values="$2"
  local count
  local value
  count="$(printf '%s\n' "$values" | sed '/^[[:space:]]*$/d' | sort -u | wc -l | tr -d ' ')"
  value="$(printf '%s\n' "$values" | sed '/^[[:space:]]*$/d' | sort -u | sed -n '1p')"
  if [[ "$count" != "1" || -z "$value" ]]; then
    echo "Expected one unique $description, found $count: $values" >&2
    exit 1
  fi
  printf '%s' "$value"
}

metadata_value() {
  local file="$1"
  local key="$2"
  sed -n "s/.*\"$key\": \"\\([^\"]*\\)\".*/\\1/p" "$file" | head -1
}

metadata_number() {
  local file="$1"
  local key="$2"
  sed -n "s/.*\"$key\": \\([0-9][0-9]*\\).*/\\1/p" "$file" | head -1
}

ANDROID_VERSION_NAME="$(
  sed -n 's/.*versionName = "\([^"]*\)".*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
ANDROID_VERSION_CODE="$(
  sed -n 's/.*versionCode = \([0-9][0-9]*\).*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
IOS_MARKETING_VERSION="$(single_unique_value "iOS MARKETING_VERSION" "$(
  sed -n 's/.*MARKETING_VERSION = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"
IOS_BUILD_VERSION="$(single_unique_value "iOS CURRENT_PROJECT_VERSION" "$(
  sed -n 's/.*CURRENT_PROJECT_VERSION = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"

if [[ -z "$ANDROID_VERSION_NAME" || -z "$ANDROID_VERSION_CODE" ]]; then
  echo "Could not read Android versionName/versionCode from $ANDROID_BUILD_FILE." >&2
  exit 1
fi
if [[ "$ANDROID_VERSION_NAME" != "$IOS_MARKETING_VERSION" ]]; then
  echo "Android versionName ($ANDROID_VERSION_NAME) must match iOS MARKETING_VERSION ($IOS_MARKETING_VERSION)." >&2
  exit 1
fi
if [[ "$ANDROID_VERSION_CODE" != "$IOS_BUILD_VERSION" ]]; then
  echo "Android versionCode ($ANDROID_VERSION_CODE) must match iOS CURRENT_PROJECT_VERSION ($IOS_BUILD_VERSION)." >&2
  exit 1
fi

if [[ "$INCLUDE_BUILT_METADATA" == "true" ]]; then
  for metadata_file in "$DEBUG_METADATA_FILE" "$RELEASE_METADATA_FILE"; do
    if [[ ! -f "$metadata_file" ]]; then
      echo "Missing Android APK metadata for built-version alignment: $metadata_file" >&2
      exit 1
    fi
    BUILT_VERSION_NAME="$(metadata_value "$metadata_file" versionName)"
    BUILT_VERSION_CODE="$(metadata_number "$metadata_file" versionCode)"
    if [[ "$BUILT_VERSION_NAME" != "$ANDROID_VERSION_NAME" ]]; then
      echo "Built Android versionName ($BUILT_VERSION_NAME) must match source versionName ($ANDROID_VERSION_NAME): $metadata_file" >&2
      exit 1
    fi
    if [[ "$BUILT_VERSION_CODE" != "$ANDROID_VERSION_CODE" ]]; then
      echo "Built Android versionCode ($BUILT_VERSION_CODE) must match source versionCode ($ANDROID_VERSION_CODE): $metadata_file" >&2
      exit 1
    fi
  done
fi

echo "Version alignment gate passed: version $ANDROID_VERSION_NAME build $ANDROID_VERSION_CODE."
