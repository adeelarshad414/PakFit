#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"
ANDROID_STRINGS="$ROOT_DIR/app/src/main/res/values/strings.xml"
STORE_LISTING_FILE="$ROOT_DIR/docs/store-listing.md"

for required_file in "$ANDROID_BUILD_FILE" "$IOS_PROJECT_FILE" "$ANDROID_STRINGS" "$STORE_LISTING_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing store-listing gate input: $required_file" >&2
    exit 1
  fi
done

single_unique_value() {
  local label="$1"
  local values="$2"
  local unique
  unique="$(printf '%s\n' "$values" | sed '/^[[:space:]]*$/d' | sort -u)"
  local count
  count="$(printf '%s\n' "$unique" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')"
  if [[ "$count" != "1" ]]; then
    echo "$label must have exactly one unique value. Found:" >&2
    printf '%s\n' "$unique" >&2
    exit 1
  fi
  printf '%s\n' "$unique"
}

require_text() {
  local file="$1"
  local text="$2"
  local description="$3"
  if ! grep -Fq "$text" "$file"; then
    echo "$description is missing from $file: $text" >&2
    exit 1
  fi
}

ANDROID_VERSION_NAME="$(
  sed -n 's/.*versionName = "\([^"]*\)".*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
ANDROID_VERSION_CODE="$(
  sed -n 's/.*versionCode = \([0-9][0-9]*\).*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
ANDROID_APPLICATION_ID="$(
  sed -n 's/.*applicationId = "\([^"]*\)".*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
ANDROID_APP_NAME="$(
  sed -n 's/.*<string name="app_name">\([^<]*\)<\/string>.*/\1/p' "$ANDROID_STRINGS" | head -1
)"
IOS_MARKETING_VERSION="$(single_unique_value "iOS MARKETING_VERSION" "$(
  sed -n 's/.*MARKETING_VERSION = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"
IOS_BUILD_VERSION="$(single_unique_value "iOS CURRENT_PROJECT_VERSION" "$(
  sed -n 's/.*CURRENT_PROJECT_VERSION = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"
IOS_BUNDLE_ID="$(single_unique_value "iOS PRODUCT_BUNDLE_IDENTIFIER" "$(
  sed -n 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/p' "$IOS_PROJECT_FILE"
)")"

if [[ -z "$ANDROID_VERSION_NAME" || -z "$ANDROID_VERSION_CODE" || -z "$ANDROID_APPLICATION_ID" || -z "$ANDROID_APP_NAME" ]]; then
  echo "Could not read Android app identity/version for store-listing validation." >&2
  exit 1
fi
if [[ "$ANDROID_VERSION_NAME" != "$IOS_MARKETING_VERSION" || "$ANDROID_VERSION_CODE" != "$IOS_BUILD_VERSION" ]]; then
  echo "Store-listing gate requires Android/iOS versions to align before validating release notes." >&2
  exit 1
fi

RELEASE_NOTES_FILE="$ROOT_DIR/docs/release-notes/PakFit-v${ANDROID_VERSION_NAME}.md"
if [[ ! -f "$RELEASE_NOTES_FILE" ]]; then
  echo "Missing versioned release notes for $ANDROID_VERSION_NAME: $RELEASE_NOTES_FILE" >&2
  exit 1
fi

require_text "$STORE_LISTING_FILE" "Listing version: $ANDROID_VERSION_NAME" "Current listing version"
require_text "$STORE_LISTING_FILE" "App name: $ANDROID_APP_NAME" "Store app name"
require_text "$STORE_LISTING_FILE" "Android package name: $ANDROID_APPLICATION_ID" "Android package name"
require_text "$STORE_LISTING_FILE" "iOS bundle identifier: $IOS_BUNDLE_ID" "iOS bundle identifier"
require_text "$STORE_LISTING_FILE" "Pakistani" "Pakistani audience positioning"
require_text "$STORE_LISTING_FILE" "does not diagnose, treat disease, prescribe therapy, or replace a clinician" "Clinical boundary copy"
require_text "$STORE_LISTING_FILE" "No account, ads, analytics SDK, push notifications, remote photo upload, or cloud sync is enabled in this build." "Current privacy boundary"
require_text "$STORE_LISTING_FILE" "Privacy policy URL: TBD public hosted URL before public store submission." "Public privacy-policy boundary"
require_text "$RELEASE_NOTES_FILE" "PakFit v${ANDROID_VERSION_NAME} Release Notes" "Release notes title"
require_text "$RELEASE_NOTES_FILE" "version ${ANDROID_VERSION_NAME} build ${ANDROID_VERSION_CODE}" "Release notes version/build evidence"

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep not found; install rg to run the store listing source-language gate." >&2
  exit 1
fi
if rg -n "Urdu|اردو|[\u0600-\u06FF]" "$STORE_LISTING_FILE" "$RELEASE_NOTES_FILE"; then
  echo "Store listing and release notes must stay English-only for the current release." >&2
  exit 1
fi

if grep -Eiq "guaranteed weight loss|guarantee(s|d)? results|cure(s|d)?|reverse(s|d)? diabetes|diagnoses disease|diagnose(s|d)? disease|treats disease|prescribes? medication|replaces (a )?(doctor|clinician|dietitian|physiotherapist)" "$STORE_LISTING_FILE" "$RELEASE_NOTES_FILE"; then
  echo "Unsafe public medical or outcome claim detected in store listing/release notes." >&2
  exit 1
fi

echo "Store listing gate passed: PakFit $ANDROID_VERSION_NAME build $ANDROID_VERSION_CODE."
