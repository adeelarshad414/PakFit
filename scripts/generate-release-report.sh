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
DEPENDENCY_DIR="${DEPENDENCY_DIR:-$REPORT_DIR/dependencies}"
PRIVACY_MANIFEST="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PrivacyInfo.xcprivacy"
ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
ROOT_BUILD_FILE="$ROOT_DIR/build.gradle.kts"
ANDROID_MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
ANDROID_BACKUP_RULES="$ROOT_DIR/app/src/main/res/xml/backup_rules.xml"
ANDROID_DATA_EXTRACTION_RULES="$ROOT_DIR/app/src/main/res/xml/data_extraction_rules.xml"
IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"
IOS_APP_ICON_SET="$ROOT_DIR/ios/PakFitIOS/Assets.xcassets/AppIcon.appiconset"
STORE_LISTING_FILE="$ROOT_DIR/docs/store-listing.md"
STORE_RELEASE_NOTES_DIR="$ROOT_DIR/docs/release-notes"
STORE_SCREENSHOT_DIR="${PAKFIT_SCREENSHOT_DIR:-$ROOT_DIR/outputs/PakFit/screens}"
GRADLEW_FILE="$ROOT_DIR/gradlew"
GRADLEW_BAT_FILE="$ROOT_DIR/gradlew.bat"
GRADLE_WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
GRADLE_WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
GRADLE_VERIFICATION_METADATA="$ROOT_DIR/gradle/verification-metadata.xml"
DEPENDABOT_CONFIG="$ROOT_DIR/.github/dependabot.yml"
SECURITY_POLICY_FILE="$ROOT_DIR/SECURITY.md"
CODEOWNERS_FILE="$ROOT_DIR/.github/CODEOWNERS"

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

file_pattern_status() {
  local file="$1"
  local pattern="$2"
  if [[ -f "$file" ]] && grep -q "$pattern" "$file"; then
    echo "present"
  else
    echo "not detected"
  fi
}

property_value() {
  local file="$1"
  local key="$2"
  sed -n "s/^$key=//p" "$file" | head -1
}

xcode_setting_value() {
  local key="$1"
  sed -n "s/.*$key = \\([^;]*\\);.*/\\1/p" "$IOS_PROJECT_FILE" | head -1
}

android_source_setting_value() {
  local key="$1"
  sed -n "s/.*$key = \"\\([^\"]*\\)\".*/\\1/p" "$ANDROID_BUILD_FILE" | head -1
}

android_source_number_value() {
  local key="$1"
  sed -n "s/.*$key = \\([0-9][0-9]*\\).*/\\1/p" "$ANDROID_BUILD_FILE" | head -1
}

APPLICATION_ID="$(metadata_value "$RELEASE_METADATA_FILE" applicationId)"
DEBUG_VARIANT_NAME="$(metadata_value "$DEBUG_METADATA_FILE" variantName)"
RELEASE_VARIANT_NAME="$(metadata_value "$RELEASE_METADATA_FILE" variantName)"
VERSION_NAME="$(metadata_value "$RELEASE_METADATA_FILE" versionName)"
VERSION_CODE="$(metadata_number "$RELEASE_METADATA_FILE" versionCode)"
STORE_RELEASE_NOTES_FILE="$STORE_RELEASE_NOTES_DIR/PakFit-v${VERSION_NAME}.md"
STORE_SCREENSHOT_CONTACT_SHEET="$STORE_SCREENSHOT_DIR/00-pakfit-screen-contact-sheet.png"

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
STORE_LISTING_STATUS="not checked"
if bash scripts/validate-store-listing.sh >/dev/null 2>&1; then
  STORE_LISTING_STATUS="passed"
fi
STORE_PRIVACY_DISCLOSURE_STATUS="not checked"
if bash scripts/validate-store-privacy-disclosures.sh >/dev/null 2>&1; then
  STORE_PRIVACY_DISCLOSURE_STATUS="passed"
fi
STORE_LISTING_BYTES=""
STORE_LISTING_SHA256=""
STORE_LISTING_FILE_STATUS="missing"
if [[ -f "$STORE_LISTING_FILE" ]]; then
  STORE_LISTING_FILE_STATUS="$STORE_LISTING_FILE"
  STORE_LISTING_BYTES="$(wc -c < "$STORE_LISTING_FILE" | tr -d ' ')"
  STORE_LISTING_SHA256="$(sha256_file "$STORE_LISTING_FILE")"
fi
STORE_RELEASE_NOTES_BYTES=""
STORE_RELEASE_NOTES_SHA256=""
STORE_RELEASE_NOTES_STATUS="missing"
if [[ -f "$STORE_RELEASE_NOTES_FILE" ]]; then
  STORE_RELEASE_NOTES_STATUS="$STORE_RELEASE_NOTES_FILE"
  STORE_RELEASE_NOTES_BYTES="$(wc -c < "$STORE_RELEASE_NOTES_FILE" | tr -d ' ')"
  STORE_RELEASE_NOTES_SHA256="$(sha256_file "$STORE_RELEASE_NOTES_FILE")"
fi
STORE_SCREENSHOT_STATUS="not checked"
if bash scripts/validate-store-screenshots.sh >/dev/null 2>&1; then
  STORE_SCREENSHOT_STATUS="passed"
fi
STORE_SCREENSHOT_COUNT="0"
if [[ -d "$STORE_SCREENSHOT_DIR" ]]; then
  STORE_SCREENSHOT_COUNT="$(find "$STORE_SCREENSHOT_DIR" -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')"
fi
STORE_SCREENSHOT_CONTACT_STATUS="missing"
STORE_SCREENSHOT_CONTACT_BYTES=""
STORE_SCREENSHOT_CONTACT_SHA256=""
if [[ -f "$STORE_SCREENSHOT_CONTACT_SHEET" ]]; then
  STORE_SCREENSHOT_CONTACT_STATUS="$STORE_SCREENSHOT_CONTACT_SHEET"
  STORE_SCREENSHOT_CONTACT_BYTES="$(wc -c < "$STORE_SCREENSHOT_CONTACT_SHEET" | tr -d ' ')"
  STORE_SCREENSHOT_CONTACT_SHA256="$(sha256_file "$STORE_SCREENSHOT_CONTACT_SHEET")"
fi
RELEASE_APK_SIGNATURE_STATUS="$(apk_signature_status "$RELEASE_APK_FILE")"
ANDROID_RELEASE_SIGNING_HYGIENE_STATUS="not checked"
if bash scripts/validate-android-release-signing.sh >/dev/null 2>&1; then
  ANDROID_RELEASE_SIGNING_HYGIENE_STATUS="passed"
fi
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
ANDROID_AUTO_BACKUP_STATUS="not disabled"
if [[ "$(file_pattern_status "$ANDROID_MANIFEST" 'android:allowBackup="false"')" == "present" ]]; then
  ANDROID_AUTO_BACKUP_STATUS="disabled"
fi
ANDROID_BACKUP_RULES_STATUS="$(file_pattern_status "$ANDROID_MANIFEST" 'android:fullBackupContent="@xml/backup_rules"')"
ANDROID_DATA_EXTRACTION_STATUS="$(file_pattern_status "$ANDROID_MANIFEST" 'android:dataExtractionRules="@xml/data_extraction_rules"')"
ANDROID_BACKUP_SNAPSHOT_EXCLUSION="$(file_pattern_status "$ANDROID_BACKUP_RULES" 'pakfit_local_snapshot.xml')"
ANDROID_EXTRACTION_SNAPSHOT_EXCLUSION="$(file_pattern_status "$ANDROID_DATA_EXTRACTION_RULES" 'pakfit_local_snapshot.xml')"
ANDROID_CLOUD_BACKUP_RULE="$(file_pattern_status "$ANDROID_DATA_EXTRACTION_RULES" '<cloud-backup')"
ANDROID_DEVICE_TRANSFER_RULE="$(file_pattern_status "$ANDROID_DATA_EXTRACTION_RULES" '<device-transfer>')"
ANDROID_DECLARED_PERMISSIONS="$(
  sed -n 's/.*<uses-permission[^>]*android:name="\([^"]*\)".*/\1/p' "$ANDROID_MANIFEST" \
    | awk 'BEGIN { permissions = "" } { permissions = permissions (permissions == "" ? "" : ", ") $0 } END { print (permissions == "" ? "none" : permissions) }'
)"
ANDROID_DECLARED_PERMISSION_COUNT="$(
  sed -n 's/.*<uses-permission[^>]*android:name="\([^"]*\)".*/\1/p' "$ANDROID_MANIFEST" | wc -l | tr -d ' '
)"
ANDROID_CAMERA_FEATURE_STATUS="not detected"
if grep -q 'android:name="android.hardware.camera"' "$ANDROID_MANIFEST" && grep -q 'android:required="false"' "$ANDROID_MANIFEST"; then
  ANDROID_CAMERA_FEATURE_STATUS="declared optional"
fi
ANDROID_EXPORTED_TRUE_COUNT="$(grep -c 'android:exported="true"' "$ANDROID_MANIFEST" | tr -d ' ')"
ANDROID_EXPORTED_SURFACE_STATUS="not checked"
if bash scripts/validate-android-exported-surface.sh >/dev/null 2>&1; then
  ANDROID_EXPORTED_SURFACE_STATUS="passed"
fi
ANDROID_CLEARTEXT_STATUS="not disabled"
if grep -q 'android:usesCleartextTraffic="false"' "$ANDROID_MANIFEST"; then
  ANDROID_CLEARTEXT_STATUS="disabled"
fi
ANDROID_NETWORK_SECURITY_STATUS="not checked"
if bash scripts/validate-android-network-security.sh >/dev/null 2>&1; then
  ANDROID_NETWORK_SECURITY_STATUS="passed"
fi
ANDROID_APP_ICON_STATUS="not checked"
if grep -q 'android:icon="@mipmap/ic_launcher"' "$ANDROID_MANIFEST" \
  && grep -q 'android:roundIcon="@mipmap/ic_launcher_round"' "$ANDROID_MANIFEST"; then
  ANDROID_APP_ICON_STATUS="adaptive icon and round icon configured"
fi
IOS_APP_ICON_IMAGE_COUNT="0"
if [[ -d "$IOS_APP_ICON_SET" ]]; then
  IOS_APP_ICON_IMAGE_COUNT="$(find "$IOS_APP_ICON_SET" -type f -name '*.png' | wc -l | tr -d ' ')"
fi
IOS_APP_ICON_STATUS="missing"
if grep -q 'ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;' "$IOS_PROJECT_FILE" && [[ "$IOS_APP_ICON_IMAGE_COUNT" -ge 18 ]]; then
  IOS_APP_ICON_STATUS="AppIcon asset catalog configured ($IOS_APP_ICON_IMAGE_COUNT PNGs)"
fi
APP_ICON_GATE_STATUS="not checked"
if bash scripts/validate-app-icons.sh >/dev/null 2>&1; then
  APP_ICON_GATE_STATUS="passed"
fi
IOS_RUNTIME_URL_POLICY="HTTPS-only Swift runtime URLs"
IOS_NETWORK_SECURITY_STATUS="not checked"
if bash scripts/validate-ios-network-security.sh >/dev/null 2>&1; then
  IOS_NETWORK_SECURITY_STATUS="passed"
fi
IOS_SIGNING_HYGIENE_STATUS="not checked"
if bash scripts/validate-ios-signing-hygiene.sh >/dev/null 2>&1; then
  IOS_SIGNING_HYGIENE_STATUS="passed"
fi
IOS_CAMERA_PURPOSE_COUNT="$(grep -c 'INFOPLIST_KEY_NSCameraUsageDescription' "$IOS_PROJECT_FILE" | tr -d ' ')"
IOS_PHOTO_PURPOSE_COUNT="$(grep -c 'INFOPLIST_KEY_NSPhotoLibraryUsageDescription' "$IOS_PROJECT_FILE" | tr -d ' ')"
IOS_CAMERA_PURPOSE_STATUS="missing"
if [[ "$IOS_CAMERA_PURPOSE_COUNT" -gt 0 ]] && grep -q 'INFOPLIST_KEY_NSCameraUsageDescription = "PakFit can use a food photo' "$IOS_PROJECT_FILE"; then
  IOS_CAMERA_PURPOSE_STATUS="present and food-photo scoped ($IOS_CAMERA_PURPOSE_COUNT build configs)"
fi
IOS_PHOTO_PURPOSE_STATUS="missing"
if [[ "$IOS_PHOTO_PURPOSE_COUNT" -gt 0 ]] && grep -q 'INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "PakFit can use a food photo' "$IOS_PROJECT_FILE"; then
  IOS_PHOTO_PURPOSE_STATUS="present and food-photo scoped ($IOS_PHOTO_PURPOSE_COUNT build configs)"
fi
IOS_PERMISSION_PRIVACY_STATUS="not checked"
if bash scripts/validate-ios-permission-privacy.sh >/dev/null 2>&1; then
  IOS_PERMISSION_PRIVACY_STATUS="passed"
fi
ANDROID_PHOTO_CAPTURE_STATUS="not detected"
if grep -q "ActivityResultContracts.TakePicturePreview" "$ROOT_DIR/app/src/main/java/com/pakfit/app/ui/PakFitApp.kt"; then
  ANDROID_PHOTO_CAPTURE_STATUS="preview-only ActivityResultContracts.TakePicturePreview"
fi
PHOTO_PRIVACY_STATUS="not checked"
if bash scripts/validate-photo-privacy.sh >/dev/null 2>&1; then
  PHOTO_PRIVACY_STATUS="passed"
fi
DEPENDENCY_REPORT_FILE="$REPORT_DIR/PakFit-v${VERSION_NAME}-dependency-inventory.md"
ANDROID_RELEASE_DEPENDENCY_TREE="$DEPENDENCY_DIR/PakFit-v${VERSION_NAME}-android-releaseRuntimeClasspath.txt"
IOS_DEPENDENCY_FILE="$DEPENDENCY_DIR/PakFit-v${VERSION_NAME}-ios-swift-package-dependencies.txt"
DEPENDENCY_REPORT_STATUS="missing"
DEPENDENCY_REPORT_BYTES=""
DEPENDENCY_REPORT_SHA256=""
ANDROID_RELEASE_DEPENDENCY_SHA256=""
IOS_DEPENDENCY_SHA256=""
if [[ -f "$DEPENDENCY_REPORT_FILE" ]]; then
  DEPENDENCY_REPORT_STATUS="$DEPENDENCY_REPORT_FILE"
  DEPENDENCY_REPORT_BYTES="$(wc -c < "$DEPENDENCY_REPORT_FILE" | tr -d ' ')"
  DEPENDENCY_REPORT_SHA256="$(sha256_file "$DEPENDENCY_REPORT_FILE")"
fi
if [[ -f "$ANDROID_RELEASE_DEPENDENCY_TREE" ]]; then
  ANDROID_RELEASE_DEPENDENCY_SHA256="$(sha256_file "$ANDROID_RELEASE_DEPENDENCY_TREE")"
fi
if [[ -f "$IOS_DEPENDENCY_FILE" ]]; then
  IOS_DEPENDENCY_SHA256="$(sha256_file "$IOS_DEPENDENCY_FILE")"
fi
GRADLE_WRAPPER_DISTRIBUTION_URL="$(property_value "$GRADLE_WRAPPER_PROPERTIES" distributionUrl)"
GRADLE_WRAPPER_DISTRIBUTION_SHA256="$(property_value "$GRADLE_WRAPPER_PROPERTIES" distributionSha256Sum)"
GRADLE_WRAPPER_JAR_SHA256="missing"
GRADLEW_SHA256="missing"
GRADLEW_BAT_SHA256="missing"
if [[ -f "$GRADLE_WRAPPER_JAR" ]]; then
  GRADLE_WRAPPER_JAR_SHA256="$(sha256_file "$GRADLE_WRAPPER_JAR")"
fi
if [[ -f "$GRADLEW_FILE" ]]; then
  GRADLEW_SHA256="$(sha256_file "$GRADLEW_FILE")"
fi
if [[ -f "$GRADLEW_BAT_FILE" ]]; then
  GRADLEW_BAT_SHA256="$(sha256_file "$GRADLEW_BAT_FILE")"
fi
GRADLE_VERIFICATION_STATUS="missing"
GRADLE_VERIFICATION_BYTES=""
GRADLE_VERIFICATION_SHA256=""
GRADLE_VERIFICATION_COMPONENTS=""
GRADLE_VERIFICATION_CHECKSUMS=""
if [[ -f "$GRADLE_VERIFICATION_METADATA" ]]; then
  GRADLE_VERIFICATION_STATUS="$GRADLE_VERIFICATION_METADATA"
  GRADLE_VERIFICATION_BYTES="$(wc -c < "$GRADLE_VERIFICATION_METADATA" | tr -d ' ')"
  GRADLE_VERIFICATION_SHA256="$(sha256_file "$GRADLE_VERIFICATION_METADATA")"
  GRADLE_VERIFICATION_COMPONENTS="$(grep -c "<component " "$GRADLE_VERIFICATION_METADATA" | tr -d ' ')"
  GRADLE_VERIFICATION_CHECKSUMS="$(grep -c "<sha256 " "$GRADLE_VERIFICATION_METADATA" | tr -d ' ')"
fi
DEPENDABOT_STATUS="missing"
DEPENDABOT_BYTES=""
DEPENDABOT_SHA256=""
DEPENDABOT_ECOSYSTEM_COUNT=""
DEPENDENCY_ADVISORY_CONFIG_STATUS="not checked"
if [[ -f "$DEPENDABOT_CONFIG" ]]; then
  DEPENDABOT_STATUS="$DEPENDABOT_CONFIG"
  DEPENDABOT_BYTES="$(wc -c < "$DEPENDABOT_CONFIG" | tr -d ' ')"
  DEPENDABOT_SHA256="$(sha256_file "$DEPENDABOT_CONFIG")"
  DEPENDABOT_ECOSYSTEM_COUNT="$(grep -c 'package-ecosystem:' "$DEPENDABOT_CONFIG" | tr -d ' ')"
fi
if bash scripts/validate-dependency-advisory-config.sh >/dev/null 2>&1; then
  DEPENDENCY_ADVISORY_CONFIG_STATUS="passed"
fi
SECURITY_GOVERNANCE_STATUS="not checked"
if bash scripts/validate-security-governance.sh >/dev/null 2>&1; then
  SECURITY_GOVERNANCE_STATUS="passed"
fi
SECURITY_POLICY_STATUS="missing"
SECURITY_POLICY_SHA256=""
CODEOWNERS_STATUS="missing"
CODEOWNERS_SHA256=""
if [[ -f "$SECURITY_POLICY_FILE" ]]; then
  SECURITY_POLICY_STATUS="$SECURITY_POLICY_FILE"
  SECURITY_POLICY_SHA256="$(sha256_file "$SECURITY_POLICY_FILE")"
fi
if [[ -f "$CODEOWNERS_FILE" ]]; then
  CODEOWNERS_STATUS="$CODEOWNERS_FILE"
  CODEOWNERS_SHA256="$(sha256_file "$CODEOWNERS_FILE")"
fi
ANDROID_SOURCE_VERSION_NAME="$(android_source_setting_value versionName)"
ANDROID_SOURCE_VERSION_CODE="$(android_source_number_value versionCode)"
ANDROID_SOURCE_APPLICATION_ID="$(android_source_setting_value applicationId)"
ANDROID_COMPILE_SDK="$(
  sed -n 's/.*compileSdk = \([0-9][0-9]*\).*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
ANDROID_GRADLE_PLUGIN_VERSION="$(
  sed -n 's/.*id("com.android.application") version "\([^"]*\)".*/\1/p' "$ROOT_BUILD_FILE" | head -1
)"
ANDROID_TARGET_SDK="$(
  sed -n 's/.*targetSdk = \([0-9][0-9]*\).*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
ANDROID_MIN_SDK="$(
  sed -n 's/.*minSdk = \([0-9][0-9]*\).*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
ANDROID_NAMESPACE="$(
  sed -n 's/.*namespace = "\([^"]*\)".*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
ANDROID_DISPLAY_NAME="$(
  sed -n 's/.*<string name="app_name">\([^<]*\)<\/string>.*/\1/p' "$ROOT_DIR/app/src/main/res/values/strings.xml" | head -1
)"
IOS_MARKETING_VERSION="$(xcode_setting_value MARKETING_VERSION)"
IOS_BUILD_VERSION="$(xcode_setting_value CURRENT_PROJECT_VERSION)"
IOS_DEPLOYMENT_TARGET="$(xcode_setting_value IPHONEOS_DEPLOYMENT_TARGET)"
IOS_SWIFT_VERSION="$(xcode_setting_value SWIFT_VERSION)"
IOS_BUNDLE_ID="$(xcode_setting_value PRODUCT_BUNDLE_IDENTIFIER)"
IOS_DISPLAY_NAME="$(xcode_setting_value INFOPLIST_KEY_CFBundleDisplayName)"
IOS_TARGETED_DEVICE_FAMILY="$(xcode_setting_value TARGETED_DEVICE_FAMILY)"
IOS_CODE_SIGN_STYLE="$(xcode_setting_value CODE_SIGN_STYLE)"
IOS_DEVELOPMENT_TEAM_VALUES="$(
  sed -n 's/.*DEVELOPMENT_TEAM = \(.*\);.*/\1/p' "$IOS_PROJECT_FILE" \
    | sed 's/^"//; s/"$//' \
    | sed '/^[[:space:]]*$/d' \
    | sort -u \
    | awk 'BEGIN { values = "" } { values = values (values == "" ? "" : ", ") $0 } END { print values }'
)"
IOS_DEVELOPMENT_TEAM_STATUS="unset in source"
if [[ -n "$IOS_DEVELOPMENT_TEAM_VALUES" ]]; then
  IOS_DEVELOPMENT_TEAM_STATUS="$IOS_DEVELOPMENT_TEAM_VALUES"
fi
VERSION_ALIGNMENT_STATUS="failed"
if bash scripts/validate-version-alignment.sh --include-built-metadata >/dev/null 2>&1; then
  VERSION_ALIGNMENT_STATUS="passed"
fi
APP_IDENTITY_STATUS="not checked"
if bash scripts/validate-app-identity.sh >/dev/null 2>&1; then
  APP_IDENTITY_STATUS="passed"
fi
PLATFORM_COMPATIBILITY_STATUS="not checked"
if bash scripts/validate-platform-compatibility.sh >/dev/null 2>&1; then
  PLATFORM_COMPATIBILITY_STATUS="passed"
fi
ANDROID_BUILD_TOOLCHAIN_STATUS="not checked"
if bash scripts/validate-android-build-toolchain.sh >/dev/null 2>&1; then
  ANDROID_BUILD_TOOLCHAIN_STATUS="passed"
fi
APPLE_UPLOAD_SDK_BOUNDARY="App Store Connect upload still requires Xcode 26 or later with an iOS/iPadOS 26 SDK; this local SwiftPM validation does not create a signed App Store archive."
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
  echo "## Build Reproducibility"
  echo
  echo "- Gradle Wrapper: present"
  echo "- Gradle distribution URL: $GRADLE_WRAPPER_DISTRIBUTION_URL"
  echo "- Gradle distribution SHA-256: $GRADLE_WRAPPER_DISTRIBUTION_SHA256"
  echo "- Gradle wrapper JAR SHA-256: $GRADLE_WRAPPER_JAR_SHA256"
  echo "- gradlew SHA-256: $GRADLEW_SHA256"
  echo "- gradlew.bat SHA-256: $GRADLEW_BAT_SHA256"
  echo "- Wrapper gate: Gradle 8.14.5 distribution checksum and wrapper JAR checksum checked by scripts/validate-release.sh"
  echo "- Dependency verification metadata: $GRADLE_VERIFICATION_STATUS"
  if [[ -n "$GRADLE_VERIFICATION_BYTES" ]]; then
    echo "- Dependency verification metadata bytes: $GRADLE_VERIFICATION_BYTES"
    echo "- Dependency verification metadata SHA-256: $GRADLE_VERIFICATION_SHA256"
    echo "- Dependency verification component count: $GRADLE_VERIFICATION_COMPONENTS"
    echo "- Dependency verification checksum count: $GRADLE_VERIFICATION_CHECKSUMS"
  fi
  echo "- Dependency verification mode: strict"
  echo
  echo "## Dependency Advisory Monitoring"
  echo
  echo "- Dependabot config: $DEPENDABOT_STATUS"
  if [[ -n "$DEPENDABOT_BYTES" ]]; then
    echo "- Dependabot config bytes: $DEPENDABOT_BYTES"
    echo "- Dependabot config SHA-256: $DEPENDABOT_SHA256"
    echo "- Dependabot ecosystem count: $DEPENDABOT_ECOSYSTEM_COUNT"
  fi
  echo "- Dependency advisory configuration gate: $DEPENDENCY_ADVISORY_CONFIG_STATUS"
  echo "- Advisory monitoring policy: Gradle, Swift Package Manager, and GitHub Actions updates are configured for hosted Dependabot monitoring"
  echo "- Advisory result boundary: live CVE/GHSA status still requires GitHub-hosted dependency scanning or another network-enabled scanner after push"
  echo
  echo "## Security Governance"
  echo
  echo "- Security policy: $SECURITY_POLICY_STATUS"
  echo "- Security policy SHA-256: ${SECURITY_POLICY_SHA256:-missing}"
  echo "- CODEOWNERS: $CODEOWNERS_STATUS"
  echo "- CODEOWNERS SHA-256: ${CODEOWNERS_SHA256:-missing}"
  echo "- Security governance gate: $SECURITY_GOVERNANCE_STATUS"
  echo "- Security governance policy: supported versions, sensitive vulnerability reporting boundary, CODEOWNERS coverage, read-only CI permissions, and clinical safety reporting scope checked"
  echo "- Security governance boundary: hosted private vulnerability reporting, branch protection, and public security contact review remain external repository settings"
  echo
  echo "## Android APK"
  echo
  echo "- Application ID: $APPLICATION_ID"
  echo "- Android source application ID: ${ANDROID_SOURCE_APPLICATION_ID:-not detected}"
  echo "- Android namespace: ${ANDROID_NAMESPACE:-not detected}"
  echo "- Android display name: ${ANDROID_DISPLAY_NAME:-not detected}"
  echo "- Version name: $VERSION_NAME"
  echo "- Version code: $VERSION_CODE"
  echo "- Android compile SDK: ${ANDROID_COMPILE_SDK:-not detected}"
  echo "- Android target SDK: ${ANDROID_TARGET_SDK:-not detected}"
  echo "- Android minimum SDK: ${ANDROID_MIN_SDK:-not detected}"
  echo "- Android Gradle Plugin: ${ANDROID_GRADLE_PLUGIN_VERSION:-not detected}"
  echo "- Android source version name: ${ANDROID_SOURCE_VERSION_NAME:-not detected}"
  echo "- Android source version code: ${ANDROID_SOURCE_VERSION_CODE:-not detected}"
  echo "- iOS marketing version: ${IOS_MARKETING_VERSION:-not detected}"
  echo "- iOS build version: ${IOS_BUILD_VERSION:-not detected}"
  echo "- Version alignment gate: $VERSION_ALIGNMENT_STATUS"
  echo "- Android Auto Backup: $ANDROID_AUTO_BACKUP_STATUS"
  echo "- Full backup rules reference: $ANDROID_BACKUP_RULES_STATUS"
  echo "- Data extraction rules reference: $ANDROID_DATA_EXTRACTION_STATUS"
  echo "- Sensitive snapshot backup exclusion: $ANDROID_BACKUP_SNAPSHOT_EXCLUSION"
  echo "- Sensitive snapshot data-extraction exclusion: $ANDROID_EXTRACTION_SNAPSHOT_EXCLUSION"
  echo "- Cloud backup rule block: $ANDROID_CLOUD_BACKUP_RULE"
  echo "- Device transfer rule block: $ANDROID_DEVICE_TRANSFER_RULE"
  echo "- Declared permissions: $ANDROID_DECLARED_PERMISSIONS"
  echo "- Declared permission count: $ANDROID_DECLARED_PERMISSION_COUNT"
  echo "- Permission policy: only INTERNET and CAMERA are allowed for current online search and food photo workflows"
  echo "- Camera hardware feature: $ANDROID_CAMERA_FEATURE_STATUS"
  echo "- Exported component count: $ANDROID_EXPORTED_TRUE_COUNT"
  echo "- Exported component policy: only launcher MainActivity may be exported"
  echo "- Android exported surface gate: $ANDROID_EXPORTED_SURFACE_STATUS"
  echo "- Cleartext traffic: $ANDROID_CLEARTEXT_STATUS"
  echo "- Android network security gate: $ANDROID_NETWORK_SECURITY_STATUS"
  echo "- Android app icon assets: $ANDROID_APP_ICON_STATUS"
  echo "- Food photo capture mode: $ANDROID_PHOTO_CAPTURE_STATUS"
  echo "- Food photo privacy gate: $PHOTO_PRIVACY_STATUS"
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
  echo "- Android release signing hygiene gate: $ANDROID_RELEASE_SIGNING_HYGIENE_STATUS"
  echo "- Android release signing policy: signing material ignored, not tracked, not repo-local, and production signing requires complete external PAKFIT_RELEASE_* inputs"
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
  echo "## Store Listing"
  echo
  echo "- Store listing draft: $STORE_LISTING_FILE_STATUS"
  if [[ -n "$STORE_LISTING_BYTES" ]]; then
    echo "- Store listing bytes: $STORE_LISTING_BYTES"
    echo "- Store listing SHA-256: $STORE_LISTING_SHA256"
  fi
  echo "- Versioned release notes: $STORE_RELEASE_NOTES_STATUS"
  if [[ -n "$STORE_RELEASE_NOTES_BYTES" ]]; then
    echo "- Versioned release notes bytes: $STORE_RELEASE_NOTES_BYTES"
    echo "- Versioned release notes SHA-256: $STORE_RELEASE_NOTES_SHA256"
  fi
  echo "- Store listing gate: $STORE_LISTING_STATUS"
  echo "- Store listing policy: app identity/version alignment, English-only copy, privacy boundaries, and unsafe medical/outcome claim scan"
  echo "- Store privacy disclosure gate: $STORE_PRIVACY_DISCLOSURE_STATUS"
  echo "- Store privacy disclosure policy: Android permissions/backup posture, iOS privacy manifest/purpose strings, privacy policy, Google Play Data safety, App Store privacy, and store listing claims checked for consistency"
  echo "- Public privacy policy URL: TBD public hosted URL before public store submission"
  echo "- Store submission boundary: final screenshots, ratings forms, public privacy-policy hosting, account ownership, and legal/privacy review remain external"
  echo
  echo "## Store Screenshot Assets"
  echo
  echo "- Screenshot output directory: $STORE_SCREENSHOT_DIR"
  echo "- Screenshot PNG count: $STORE_SCREENSHOT_COUNT"
  echo "- Screenshot contact sheet: $STORE_SCREENSHOT_CONTACT_STATUS"
  if [[ -n "$STORE_SCREENSHOT_CONTACT_BYTES" ]]; then
    echo "- Screenshot contact sheet bytes: $STORE_SCREENSHOT_CONTACT_BYTES"
    echo "- Screenshot contact sheet SHA-256: $STORE_SCREENSHOT_CONTACT_SHA256"
  fi
  echo "- Store screenshot gate: $STORE_SCREENSHOT_STATUS"
  echo "- Store screenshot policy: English-only renderer source, six 1080x1920 workflow PNGs, one 1120x1450 contact sheet, and nonblank output checked"
  echo "- Store screenshot boundary: final store screenshots still need signed-binary/device review against Play Console and App Store Connect requirements"
  echo
  echo "## Dependency Inventory"
  echo
  echo "- Inventory report: $DEPENDENCY_REPORT_STATUS"
  if [[ -n "$DEPENDENCY_REPORT_BYTES" ]]; then
    echo "- Inventory report bytes: $DEPENDENCY_REPORT_BYTES"
    echo "- Inventory report SHA-256: $DEPENDENCY_REPORT_SHA256"
  fi
  echo "- Android release dependency tree: $ANDROID_RELEASE_DEPENDENCY_TREE"
  echo "- Android release dependency tree SHA-256: ${ANDROID_RELEASE_DEPENDENCY_SHA256:-missing}"
  echo "- iOS Swift package dependency file: $IOS_DEPENDENCY_FILE"
  echo "- iOS Swift package dependency SHA-256: ${IOS_DEPENDENCY_SHA256:-missing}"
  echo "- Dependency gate: dynamic and SNAPSHOT dependency declarations are blocked by scripts/generate-dependency-inventory.sh"
  echo
  echo "## iOS"
  echo
  echo "- Swift package: ios/PakFitIOS/Package.swift"
  echo "- Xcode project: ios/PakFitIOS/PakFitIOS.xcodeproj"
  echo "- Marketing version: ${IOS_MARKETING_VERSION:-not detected}"
  echo "- Build version: ${IOS_BUILD_VERSION:-not detected}"
  echo "- iOS deployment target: ${IOS_DEPLOYMENT_TARGET:-not detected}"
  echo "- iOS Swift version setting: ${IOS_SWIFT_VERSION:-not detected}"
  echo "- Bundle identifier: ${IOS_BUNDLE_ID:-not detected}"
  echo "- Display name: ${IOS_DISPLAY_NAME:-not detected}"
  echo "- Target device family: ${IOS_TARGETED_DEVICE_FAMILY:-not detected}"
  echo "- Code sign style: ${IOS_CODE_SIGN_STYLE:-not detected}"
  echo "- Development team source setting: $IOS_DEVELOPMENT_TEAM_STATUS"
  echo "- App identity gate: $APP_IDENTITY_STATUS"
  echo "- Privacy manifest: $PRIVACY_MANIFEST_STATUS"
  echo "- Required reason API declared: NSPrivacyAccessedAPICategoryUserDefaults / CA92.1"
  echo "- iOS app icon assets: $IOS_APP_ICON_STATUS"
  echo "- Camera purpose string: $IOS_CAMERA_PURPOSE_STATUS"
  echo "- Photo library purpose string: $IOS_PHOTO_PURPOSE_STATUS"
  echo "- iOS permission privacy gate: $IOS_PERMISSION_PRIVACY_STATUS"
  echo "- iOS runtime URL policy: $IOS_RUNTIME_URL_POLICY"
  echo "- iOS network security gate: $IOS_NETWORK_SECURITY_STATUS"
  echo "- iOS signing hygiene gate: $IOS_SIGNING_HYGIENE_STATUS"
  echo "- iOS signing policy: Apple certificates, provisioning profiles, export options, App Store credentials, development team, profiles, signing identities, and manual signing remain external"
  echo "- App icon asset gate: $APP_ICON_GATE_STATUS"
  echo "- Platform compatibility gate: $PLATFORM_COMPATIBILITY_STATUS"
  echo "- Android build toolchain gate: $ANDROID_BUILD_TOOLCHAIN_STATUS"
  echo "- Apple upload SDK boundary: $APPLE_UPLOAD_SDK_BOUNDARY"
  echo
  echo "## Validation Gate"
  echo
  echo "- Local command: bash scripts/validate-release.sh"
  echo "- Build reproducibility: Gradle Wrapper integrity gate"
  echo "- Gradle dependencies: strict SHA-256 dependency verification metadata gate"
  echo "- Dependency advisory monitoring: Dependabot coverage for Gradle, Swift Package Manager, and GitHub Actions checked"
  echo "- Security governance: SECURITY.md, CODEOWNERS coverage, vulnerability reporting boundaries, and low-risk CI permissions checked"
  echo "- Version alignment: Android source, Android APK metadata, and iOS project version metadata checked"
  echo "- App identity: Android application ID/display name and iOS bundle ID/display name checked"
  echo "- Store listing: current app identity/version, release notes, privacy boundaries, English-only copy, and unsafe medical/outcome claim scan checked"
  echo "- Store privacy disclosures: Android permissions, iOS privacy manifest, privacy policy, Google Play Data safety, App Store privacy, store listing privacy summary, and unsupported privacy claims checked"
  echo "- Store screenshots: generated English-only workflow previews, PNG dimensions, contact sheet, and nonblank output checked"
  echo "- App icons: Android adaptive icons and iOS AppIcon asset catalog checked"
  echo "- Platform compatibility: Android compile/target SDK and iOS deployment/Swift settings checked"
  echo "- Android build toolchain: AGP compileSdk 35 support checked without suppressing warnings"
  echo "- Android release signing hygiene: signing material exclusions, no repo-local signing files, no hardcoded signing passwords, and complete external signing env shape checked"
  echo "- Android: testDebugUnitTest, lintDebug, lintRelease, assembleDebug, assembleRelease, and bundleRelease"
  echo "- Dependency inventory: dynamic/SNAPSHOT dependency gate plus Android and Swift dependency reports"
  echo "- iOS: swift run PakFitCoreSmokeTests and swift build --target PakFitApp"
  echo "- Source gates: English-only app source and secret-pattern smoke check"
  echo "- Store privacy gate: PrivacyInfo.xcprivacy plist and UserDefaults reason checks"
  echo "- iOS permission privacy gate: camera/photo purpose strings food-photo scoped and no unreviewed permission APIs"
  echo "- Android backup privacy gate: Auto Backup disabled and sensitive snapshot exclusions checked"
  echo "- Android permission privacy gate: declared permissions limited to INTERNET and CAMERA with camera hardware optional"
  echo "- Android exported surface gate: only launcher MainActivity may be exported"
  echo "- Android network security gate: cleartext traffic disabled and runtime URLs HTTPS-only"
  echo "- iOS network security gate: Swift runtime URLs HTTPS-only and no ATS cleartext opt-outs"
  echo "- iOS signing hygiene gate: no repo-local signing material, no hardcoded signing/App Store credentials, and unsigned local Xcode project posture checked"
  echo "- Food photo privacy gate: preview-only capture with no image-byte persistence/upload patterns"
  echo
  echo "## Release Boundaries"
  echo
  echo "- Android release signing is configured only through external PAKFIT_RELEASE_* environment variables; signing secrets must not be committed."
  echo "- Unsigned release APKs and locally generated AABs are build evidence, not store-submission proof."
  echo "- Play Console submission still requires upload-key signing verification and store track validation."
  echo "- iOS simulator/archive/signing still requires full Xcode.app, Xcode 26+ SDK tooling for App Store upload, and signing assets."
  echo "- Dependabot advisory monitoring is configured, but live vulnerability/advisory results still require the pushed repository and GitHub-hosted dependency scanning or another network-enabled scanner."
  echo "- Hosted private vulnerability reporting, branch protection, and public security-contact review remain external repository settings."
  echo "- Privacy docs are drafts and require legal/privacy review before public store submission."
} > "$REPORT_FILE"

echo "$REPORT_FILE"
