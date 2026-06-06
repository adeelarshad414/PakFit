#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_SOURCE_DIR="$ROOT_DIR/app/src/main/java"
ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
ROOT_BUILD_FILE="$ROOT_DIR/build.gradle.kts"
ANDROID_MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
IOS_APP_DIR="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp"
IOS_CORE_DIR="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore"
IOS_PACKAGE_FILE="$ROOT_DIR/ios/PakFitIOS/Package.swift"
DOC_FILE="$ROOT_DIR/docs/diagnostics-privacy.md"
PRIVACY_POLICY="$ROOT_DIR/docs/privacy-policy.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"
GOOGLE_PLAY_DATA_SAFETY="$ROOT_DIR/docs/google-play-data-safety.md"
APP_STORE_PRIVACY="$ROOT_DIR/docs/app-store-privacy.md"

for required_file in \
  "$ANDROID_BUILD_FILE" \
  "$ROOT_BUILD_FILE" \
  "$ANDROID_MANIFEST" \
  "$IOS_PACKAGE_FILE" \
  "$DOC_FILE" \
  "$PRIVACY_POLICY" \
  "$STORE_LISTING" \
  "$GOOGLE_PLAY_DATA_SAFETY" \
  "$APP_STORE_PRIVACY"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing diagnostic privacy gate input: $required_file" >&2
    exit 1
  fi
done

if [[ ! -d "$ANDROID_SOURCE_DIR" || ! -d "$IOS_APP_DIR" || ! -d "$IOS_CORE_DIR" ]]; then
  echo "Missing Android or iOS runtime source directory for diagnostic privacy validation." >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep not found; install rg to run the diagnostic privacy gate." >&2
  exit 1
fi

require_text() {
  local file="$1"
  local text="$2"
  local description="$3"
  if ! grep -Fq "$text" "$file"; then
    echo "$description is missing from $file: $text" >&2
    exit 1
  fi
}

block_regex() {
  local pattern="$1"
  local description="$2"
  shift 2
  if rg -n "$pattern" "$@"; then
    echo "$description detected." >&2
    exit 1
  fi
}

block_regex "android\\.util\\.Log|\\bLog\\.(v|d|i|w|e|wtf)\\s*\\(|Timber\\.|printStackTrace\\s*\\(|System\\.(out|err)\\.print" \
  "Android runtime logging or stack-trace output" \
  "$ANDROID_SOURCE_DIR"

block_regex "\\bprint\\s*\\(|\\bdebugPrint\\s*\\(|\\bNSLog\\s*\\(|\\bos_log\\s*\\(|\\bLogger\\s*\\(" \
  "iOS runtime logging output" \
  "$IOS_APP_DIR" "$IOS_CORE_DIR"

block_regex "firebase-analytics|crashlytics|sentry|bugsnag|datadog|newrelic|mixpanel|amplitude|segment|appcenter|telemetry" \
  "Unreviewed Android analytics, crash, or telemetry dependency/configuration" \
  "$ANDROID_BUILD_FILE" "$ROOT_BUILD_FILE" "$ANDROID_MANIFEST"

block_regex "FirebaseAnalytics|Crashlytics|Sentry|Bugsnag|Datadog|NewRelic|Mixpanel|Amplitude|Segment|AppCenter|Telemetry" \
  "Unreviewed iOS analytics, crash, or telemetry dependency/configuration" \
  "$IOS_PACKAGE_FILE" "$IOS_APP_DIR" "$IOS_CORE_DIR"

require_text "$DOC_FILE" "No diagnostic logs, crash reports, analytics events, or health-data telemetry are emitted in this build." "Diagnostic privacy policy"
require_text "$DOC_FILE" "Pakistani" "Diagnostic privacy audience context"
require_text "$DOC_FILE" "health data" "Diagnostic privacy health-data boundary"
require_text "$DOC_FILE" "future SDK" "Diagnostic privacy future SDK boundary"
require_text "$PRIVACY_POLICY" "No diagnostic logs, crash reports, analytics events, or health-data telemetry are emitted in this build." "Privacy policy diagnostic boundary"
require_text "$STORE_LISTING" "No diagnostic logs, crash reports, analytics events, or health-data telemetry are emitted in this build." "Store listing diagnostic boundary"
require_text "$GOOGLE_PLAY_DATA_SAFETY" "No diagnostic logs, crash reports, analytics events, or health-data telemetry are emitted in this build." "Google Play data safety diagnostic boundary"
require_text "$APP_STORE_PRIVACY" "No diagnostic logs, crash reports, analytics events, or health-data telemetry are emitted in this build." "App Store privacy diagnostic boundary"

echo "Diagnostic privacy gate passed."
