#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
IOS_PROJECT_DIR="$ROOT_DIR/ios/PakFitIOS"
IOS_PROJECT_FILE="$IOS_PROJECT_DIR/PakFitIOS.xcodeproj/project.pbxproj"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/outputs/PakFit}"

if [[ ! -f "$ANDROID_BUILD_FILE" ]]; then
  echo "Missing Android build file: $ANDROID_BUILD_FILE" >&2
  exit 1
fi
if [[ ! -f "$IOS_PROJECT_FILE" ]]; then
  echo "Missing iOS project file: $IOS_PROJECT_FILE" >&2
  exit 1
fi
if ! command -v zip >/dev/null 2>&1; then
  echo "zip is required to export the iOS application handoff archive." >&2
  exit 1
fi

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

sha256_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  else
    echo "No SHA-256 tool found." >&2
    exit 1
  fi
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

for required_path in \
  "$IOS_PROJECT_DIR/Package.swift" \
  "$IOS_PROJECT_DIR/PakFitIOS.xcodeproj" \
  "$IOS_PROJECT_DIR/Sources" \
  "$IOS_PROJECT_DIR/Tests" \
  "$IOS_PROJECT_DIR/Assets.xcassets" \
  "$ROOT_DIR/ios/README.md"; do
  if [[ ! -e "$required_path" ]]; then
    echo "Missing iOS handoff input: $required_path" >&2
    exit 1
  fi
done

mkdir -p "$OUTPUT_DIR"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pakfit-ios-handoff.XXXXXX")"
cleanup() {
  rm -rf "$STAGING_DIR"
}
trap cleanup EXIT

HANDOFF_ROOT="$STAGING_DIR/PakFitIOS-v${ANDROID_VERSION_NAME}"
mkdir -p "$HANDOFF_ROOT"

cp "$IOS_PROJECT_DIR/Package.swift" "$HANDOFF_ROOT/"
cp -R "$IOS_PROJECT_DIR/PakFitIOS.xcodeproj" "$HANDOFF_ROOT/"
cp -R "$IOS_PROJECT_DIR/Sources" "$HANDOFF_ROOT/"
cp -R "$IOS_PROJECT_DIR/Tests" "$HANDOFF_ROOT/"
cp -R "$IOS_PROJECT_DIR/Assets.xcassets" "$HANDOFF_ROOT/"
cp "$ROOT_DIR/ios/README.md" "$HANDOFF_ROOT/README.md"

XCODE_STATUS="not available in this environment"
if command -v xcodebuild >/dev/null 2>&1 && xcodebuild -version >/dev/null 2>&1; then
  XCODE_STATUS="$(xcodebuild -version | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
fi

MANIFEST_FILE="$STAGING_DIR/PakFitIOS-HANDOFF-MANIFEST.md"
{
  echo "# PakFit iOS Application Handoff"
  echo
  echo "- Version: $ANDROID_VERSION_NAME"
  echo "- Build: $ANDROID_VERSION_CODE"
  echo "- Bundle identifier: com.pakfit.ios"
  echo "- Contents: SwiftUI app target, PakFitCore Swift module, smoke-test target, XCTest target, Xcode project, app icon catalog, and iOS README."
  echo "- Local validation: scripts/validate-release.sh runs Swift smoke tests and swift build --target PakFitApp."
  echo "- Toolchain status: $XCODE_STATUS"
  echo "- Boundary: signed IPA, simulator .app, App Store archive, provisioning profiles, Apple certificates, and App Store Connect upload require full Xcode.app and external Apple signing assets."
  echo "- Privacy posture: food-photo purpose strings, PrivacyInfo.xcprivacy, HTTPS-only runtime URLs, and signing hygiene are checked by release gates."
} > "$MANIFEST_FILE"

CHECKSUM_FILE="$STAGING_DIR/PakFitIOS-HANDOFF-CHECKSUMS.txt"
(
  cd "$STAGING_DIR"
  find "PakFitIOS-v${ANDROID_VERSION_NAME}" -type f | sort | while IFS= read -r file; do
    sha256_file "$file"
  done
) > "$CHECKSUM_FILE"

DESTINATION="$OUTPUT_DIR/PakFit-v${ANDROID_VERSION_NAME}-ios-app-handoff.zip"
(
  cd "$STAGING_DIR"
  zip -qry "$DESTINATION" "PakFitIOS-v${ANDROID_VERSION_NAME}" PakFitIOS-HANDOFF-MANIFEST.md PakFitIOS-HANDOFF-CHECKSUMS.txt
)

echo "$DESTINATION"
