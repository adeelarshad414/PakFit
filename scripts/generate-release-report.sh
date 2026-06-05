#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DEBUG_METADATA_FILE="$ROOT_DIR/app/build/outputs/apk/debug/output-metadata.json"
RELEASE_METADATA_FILE="$ROOT_DIR/app/build/outputs/apk/release/output-metadata.json"
DEBUG_APK_FILE="${DEBUG_APK_FILE:-$ROOT_DIR/app/build/outputs/apk/debug/app-debug.apk}"
RELEASE_APK_FILE="${RELEASE_APK_FILE:-}"
RELEASE_AAB_FILE="${RELEASE_AAB_FILE:-$ROOT_DIR/app/build/outputs/bundle/release/app-release.aab}"
RELEASE_MAPPING_FILE="${RELEASE_MAPPING_FILE:-$ROOT_DIR/app/build/outputs/mapping/release/mapping.txt}"
REPORT_DIR="${REPORT_DIR:-$ROOT_DIR/outputs/PakFit/reports}"
PRIVACY_MANIFEST="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PrivacyInfo.xcprivacy"
ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"

if [[ ! -f "$DEBUG_METADATA_FILE" || ! -f "$RELEASE_METADATA_FILE" ]]; then
  echo "Missing Android APK metadata. Run scripts/validate-release.sh first." >&2
  exit 1
fi

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

metadata_output_path() {
  local file="$1"
  local output_dir="$2"
  local output_file
  output_file="$(metadata_value "$file" outputFile)"
  if [[ -z "$output_file" ]]; then
    echo "Could not read outputFile from $file." >&2
    exit 1
  fi
  echo "$output_dir/$output_file"
}

if [[ -z "$RELEASE_APK_FILE" ]]; then
  RELEASE_APK_FILE="$(metadata_output_path "$RELEASE_METADATA_FILE" "$ROOT_DIR/app/build/outputs/apk/release")"
fi

if [[ ! -f "$DEBUG_APK_FILE" ]]; then
  echo "Missing debug APK file: $DEBUG_APK_FILE. Run scripts/validate-release.sh first." >&2
  exit 1
fi

if [[ ! -f "$RELEASE_APK_FILE" ]]; then
  echo "Missing release APK file: $RELEASE_APK_FILE. Run scripts/validate-release.sh first." >&2
  exit 1
fi

if [[ ! -f "$RELEASE_AAB_FILE" ]]; then
  echo "Missing release AAB file: $RELEASE_AAB_FILE. Run scripts/validate-release.sh first." >&2
  exit 1
fi

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

find_apksigner() {
  if command -v apksigner >/dev/null 2>&1; then
    command -v apksigner
    return 0
  fi

  local sdk_root
  for sdk_root in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk" "/opt/homebrew/share/android-commandlinetools"; do
    if [[ -n "$sdk_root" && -d "$sdk_root/build-tools" ]]; then
      find "$sdk_root/build-tools" -type f -name apksigner 2>/dev/null | sort | tail -1
      return 0
    fi
  done

  return 1
}

apk_signature_status() {
  local apk_file="$1"
  local apksigner
  apksigner="$(find_apksigner || true)"

  if [[ -z "$apksigner" ]]; then
    echo "not verified; apksigner unavailable"
    return 0
  fi

  if "$apksigner" verify "$apk_file" >/dev/null 2>&1; then
    echo "signature verifies with apksigner"
  else
    echo "not signed or signature verification failed"
  fi
}

gradle_flag_status() {
  local pattern="$1"
  if grep -q "$pattern" "$ANDROID_BUILD_FILE"; then
    echo "enabled"
  else
    echo "not detected"
  fi
}

xcode_setting_value() {
  local key="$1"
  sed -n "s/.*$key = \\([^;]*\\);.*/\\1/p" "$IOS_PROJECT_FILE" | head -1
}

APPLICATION_ID="$(metadata_value "$RELEASE_METADATA_FILE" applicationId)"
DEBUG_VARIANT_NAME="$(metadata_value "$DEBUG_METADATA_FILE" variantName)"
RELEASE_VARIANT_NAME="$(metadata_value "$RELEASE_METADATA_FILE" variantName)"
VERSION_NAME="$(metadata_value "$RELEASE_METADATA_FILE" versionName)"
VERSION_CODE="$(metadata_number "$RELEASE_METADATA_FILE" versionCode)"

if [[ -z "$VERSION_NAME" || -z "$VERSION_CODE" || -z "$APPLICATION_ID" || -z "$DEBUG_VARIANT_NAME" || -z "$RELEASE_VARIANT_NAME" ]]; then
  echo "Could not read APK metadata from Android output-metadata.json files." >&2
  exit 1
fi

DEBUG_APK_SHA256="$(sha256_file "$DEBUG_APK_FILE")"
DEBUG_APK_BYTES="$(wc -c < "$DEBUG_APK_FILE" | tr -d ' ')"
RELEASE_APK_SHA256="$(sha256_file "$RELEASE_APK_FILE")"
RELEASE_APK_BYTES="$(wc -c < "$RELEASE_APK_FILE" | tr -d ' ')"
RELEASE_AAB_SHA256="$(sha256_file "$RELEASE_AAB_FILE")"
RELEASE_AAB_BYTES="$(wc -c < "$RELEASE_AAB_FILE" | tr -d ' ')"
RELEASE_APK_SIGNATURE_STATUS="$(apk_signature_status "$RELEASE_APK_FILE")"
RELEASE_SIGNING_ENV_STATUS="not configured in this run"
if [[ -n "${PAKFIT_RELEASE_STORE_FILE:-}" && -n "${PAKFIT_RELEASE_STORE_PASSWORD:-}" && -n "${PAKFIT_RELEASE_KEY_ALIAS:-}" && -n "${PAKFIT_RELEASE_KEY_PASSWORD:-}" ]]; then
  RELEASE_SIGNING_ENV_STATUS="configured from PAKFIT_RELEASE_* environment variables"
fi
RELEASE_MINIFY_STATUS="$(gradle_flag_status "isMinifyEnabled = true")"
RELEASE_RESOURCE_SHRINK_STATUS="$(gradle_flag_status "isShrinkResources = true")"
RELEASE_PROGUARD_STATUS="not detected"
if [[ -f "$ROOT_DIR/app/proguard-rules.pro" ]] && grep -q "proguard-android-optimize.txt" "$ANDROID_BUILD_FILE"; then
  RELEASE_PROGUARD_STATUS="default optimized rules plus app/proguard-rules.pro"
fi
RELEASE_MAPPING_STATUS="missing"
RELEASE_MAPPING_BYTES=""
RELEASE_MAPPING_SHA256=""
if [[ -f "$RELEASE_MAPPING_FILE" ]]; then
  RELEASE_MAPPING_STATUS="$RELEASE_MAPPING_FILE"
  RELEASE_MAPPING_BYTES="$(wc -c < "$RELEASE_MAPPING_FILE" | tr -d ' ')"
  RELEASE_MAPPING_SHA256="$(sha256_file "$RELEASE_MAPPING_FILE")"
fi
IOS_MARKETING_VERSION="$(xcode_setting_value MARKETING_VERSION)"
IOS_BUILD_VERSION="$(xcode_setting_value CURRENT_PROJECT_VERSION)"
GIT_SHA="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
REPORT_TIME_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
REPORT_FILE="$REPORT_DIR/PakFit-v${VERSION_NAME}-release-evidence-report.md"

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
  echo "- Version name: $VERSION_NAME"
  echo "- Version code: $VERSION_CODE"
  echo
  echo "### Debug APK"
  echo
  echo "- Variant: $DEBUG_VARIANT_NAME"
  echo "- APK path: $DEBUG_APK_FILE"
  echo "- APK bytes: $DEBUG_APK_BYTES"
  echo "- APK SHA-256: $DEBUG_APK_SHA256"
  echo
  echo "### Release APK"
  echo
  echo "- Variant: $RELEASE_VARIANT_NAME"
  echo "- APK path: $RELEASE_APK_FILE"
  echo "- APK bytes: $RELEASE_APK_BYTES"
  echo "- APK SHA-256: $RELEASE_APK_SHA256"
  echo "- APK signature status: $RELEASE_APK_SIGNATURE_STATUS"
  echo "- Release signing environment: $RELEASE_SIGNING_ENV_STATUS"
  echo "- R8 minification: $RELEASE_MINIFY_STATUS"
  echo "- Resource shrinking: $RELEASE_RESOURCE_SHRINK_STATUS"
  echo "- ProGuard/R8 rules: $RELEASE_PROGUARD_STATUS"
  echo "- R8 mapping path: $RELEASE_MAPPING_STATUS"
  if [[ -n "$RELEASE_MAPPING_BYTES" ]]; then
    echo "- R8 mapping bytes: $RELEASE_MAPPING_BYTES"
    echo "- R8 mapping SHA-256: $RELEASE_MAPPING_SHA256"
  fi
  echo
  echo "### Release Android App Bundle"
  echo
  echo "- AAB path: $RELEASE_AAB_FILE"
  echo "- AAB bytes: $RELEASE_AAB_BYTES"
  echo "- AAB SHA-256: $RELEASE_AAB_SHA256"
  echo
  echo "## iOS"
  echo
  echo "- Swift package: ios/PakFitIOS/Package.swift"
  echo "- Xcode project: ios/PakFitIOS/PakFitIOS.xcodeproj"
  echo "- Marketing version: ${IOS_MARKETING_VERSION:-not detected}"
  echo "- Build version: ${IOS_BUILD_VERSION:-not detected}"
  echo "- Privacy manifest: $PRIVACY_MANIFEST_STATUS"
  echo "- Required reason API declared: NSPrivacyAccessedAPICategoryUserDefaults / CA92.1"
  echo
  echo "## Validation Gate"
  echo
  echo "- Local command: bash scripts/validate-release.sh"
  echo "- Android: testDebugUnitTest, lintDebug, lintRelease, assembleDebug, assembleRelease, and bundleRelease"
  echo "- iOS: swift run PakFitCoreSmokeTests and swift build --target PakFitApp"
  echo "- Source gates: English-only app source and secret-pattern smoke check"
  echo "- Store privacy gate: PrivacyInfo.xcprivacy plist and UserDefaults reason checks"
  echo
  echo "## Release Boundaries"
  echo
  echo "- Android release signing is configured only through external PAKFIT_RELEASE_* environment variables; signing secrets must not be committed."
  echo "- Unsigned release APKs and locally generated AABs are build evidence, not store-submission proof."
  echo "- Play Console submission still requires upload-key signing verification and store track validation."
  echo "- iOS simulator/archive/signing still requires full Xcode.app and signing assets."
  echo "- Privacy docs are drafts and require legal/privacy review before public store submission."
} > "$REPORT_FILE"

echo "$REPORT_FILE"
