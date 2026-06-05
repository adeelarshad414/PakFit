#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

METADATA_FILE="$ROOT_DIR/app/build/outputs/apk/debug/output-metadata.json"
APK_FILE="${APK_FILE:-$ROOT_DIR/app/build/outputs/apk/debug/app-debug.apk}"
REPORT_DIR="${REPORT_DIR:-$ROOT_DIR/outputs/PakFit/reports}"
PRIVACY_MANIFEST="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PrivacyInfo.xcprivacy"

if [[ ! -f "$METADATA_FILE" ]]; then
  echo "Missing Android APK metadata. Run scripts/validate-release.sh first." >&2
  exit 1
fi

if [[ ! -f "$APK_FILE" ]]; then
  echo "Missing APK file: $APK_FILE. Run scripts/validate-release.sh first." >&2
  exit 1
fi

metadata_value() {
  local key="$1"
  sed -n "s/.*\"$key\": \"\\([^\"]*\\)\".*/\\1/p" "$METADATA_FILE" | head -1
}

metadata_number() {
  local key="$1"
  sed -n "s/.*\"$key\": \\([0-9][0-9]*\\).*/\\1/p" "$METADATA_FILE" | head -1
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

APPLICATION_ID="$(metadata_value applicationId)"
VARIANT_NAME="$(metadata_value variantName)"
VERSION_NAME="$(metadata_value versionName)"
VERSION_CODE="$(metadata_number versionCode)"

if [[ -z "$VERSION_NAME" || -z "$VERSION_CODE" || -z "$APPLICATION_ID" || -z "$VARIANT_NAME" ]]; then
  echo "Could not read APK metadata from $METADATA_FILE." >&2
  exit 1
fi

APK_SHA256="$(sha256_file "$APK_FILE")"
APK_BYTES="$(wc -c < "$APK_FILE" | tr -d ' ')"
GIT_SHA="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
REPORT_TIME_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
REPORT_FILE="$REPORT_DIR/PakFit-v${VERSION_NAME}-${VARIANT_NAME}-release-report.md"

if [[ ! -f "$PRIVACY_MANIFEST" ]]; then
  PRIVACY_MANIFEST_STATUS="missing"
else
  PRIVACY_MANIFEST_STATUS="present"
  if command -v plutil >/dev/null 2>&1; then
    if plutil -lint "$PRIVACY_MANIFEST" >/dev/null; then
      PRIVACY_MANIFEST_STATUS="present and plist-valid"
    else
      PRIVACY_MANIFEST_STATUS="present but plist-invalid"
    fi
  fi
fi

WORKTREE_STATUS="$(git status --short 2>/dev/null || true)"
if [[ -z "$WORKTREE_STATUS" ]]; then
  WORKTREE_STATUS="clean"
fi

mkdir -p "$REPORT_DIR"

{
  echo "# PakFit Release Evidence Report"
  echo
  echo "- Generated UTC: $REPORT_TIME_UTC"
  echo "- Git branch: $GIT_BRANCH"
  echo "- Git SHA: $GIT_SHA"
  echo "- Worktree status: $WORKTREE_STATUS"
  echo
  echo "## Android APK"
  echo
  echo "- Application ID: $APPLICATION_ID"
  echo "- Variant: $VARIANT_NAME"
  echo "- Version name: $VERSION_NAME"
  echo "- Version code: $VERSION_CODE"
  echo "- APK path: $APK_FILE"
  echo "- APK bytes: $APK_BYTES"
  echo "- APK SHA-256: $APK_SHA256"
  echo
  echo "## iOS"
  echo
  echo "- Swift package: ios/PakFitIOS/Package.swift"
  echo "- Xcode project: ios/PakFitIOS/PakFitIOS.xcodeproj"
  echo "- Privacy manifest: $PRIVACY_MANIFEST_STATUS"
  echo "- Required reason API declared: NSPrivacyAccessedAPICategoryUserDefaults / CA92.1"
  echo
  echo "## Validation Gate"
  echo
  echo "- Local command: bash scripts/validate-release.sh"
  echo "- Android: testDebugUnitTest and assembleDebug"
  echo "- iOS: swift run PakFitCoreSmokeTests and swift build --target PakFitApp"
  echo "- Source gates: English-only app source and secret-pattern smoke check"
  echo "- Store privacy gate: PrivacyInfo.xcprivacy plist and UserDefaults reason checks"
  echo
  echo "## Release Boundaries"
  echo
  echo "- Debug APK only; production signing is not configured in this repository."
  echo "- iOS simulator/archive/signing still requires full Xcode.app and signing assets."
  echo "- Privacy docs are drafts and require legal/privacy review before public store submission."
} > "$REPORT_FILE"

echo "$REPORT_FILE"
