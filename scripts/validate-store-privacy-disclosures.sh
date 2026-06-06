#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
ANDROID_BACKUP_RULES="$ROOT_DIR/app/src/main/res/xml/backup_rules.xml"
ANDROID_DATA_EXTRACTION_RULES="$ROOT_DIR/app/src/main/res/xml/data_extraction_rules.xml"
IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"
IOS_PRIVACY_MANIFEST="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PrivacyInfo.xcprivacy"
PRIVACY_POLICY="$ROOT_DIR/docs/privacy-policy.md"
GOOGLE_PLAY_DATA_SAFETY="$ROOT_DIR/docs/google-play-data-safety.md"
APP_STORE_PRIVACY="$ROOT_DIR/docs/app-store-privacy.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"

for required_file in \
  "$ANDROID_MANIFEST" \
  "$ANDROID_BACKUP_RULES" \
  "$ANDROID_DATA_EXTRACTION_RULES" \
  "$IOS_PROJECT_FILE" \
  "$IOS_PRIVACY_MANIFEST" \
  "$PRIVACY_POLICY" \
  "$GOOGLE_PLAY_DATA_SAFETY" \
  "$APP_STORE_PRIVACY" \
  "$STORE_LISTING"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing store privacy disclosure input: $required_file" >&2
    exit 1
  fi
done

require_text() {
  local file="$1"
  local text="$2"
  local description="$3"
  if ! grep -Fqi "$text" "$file"; then
    echo "$description is missing from $file: $text" >&2
    exit 1
  fi
}

require_absent() {
  local file="$1"
  local pattern="$2"
  local description="$3"
  if rg -n "$pattern" "$file"; then
    echo "$description must not appear in $file." >&2
    exit 1
  fi
}

declared_permissions="$(
  sed -n 's/.*<uses-permission[^>]*android:name="\([^"]*\)".*/\1/p' "$ANDROID_MANIFEST" | sort
)"
expected_permissions="$(
  printf '%s\n' \
    "android.permission.CAMERA" \
    "android.permission.INTERNET" \
    | sort
)"
if [[ "$declared_permissions" != "$expected_permissions" ]]; then
  echo "Android declared permissions must match current privacy disclosures." >&2
  echo "Expected:" >&2
  printf '%s\n' "$expected_permissions" >&2
  echo "Found:" >&2
  printf '%s\n' "$declared_permissions" >&2
  exit 1
fi

require_text "$ANDROID_MANIFEST" 'android:allowBackup="false"' "Android Auto Backup disabled posture"
require_text "$ANDROID_BACKUP_RULES" 'pakfit_local_snapshot.xml' "Android backup exclusion"
require_text "$ANDROID_DATA_EXTRACTION_RULES" 'pakfit_local_snapshot.xml' "Android data extraction exclusion"
require_text "$ANDROID_DATA_EXTRACTION_RULES" '<cloud-backup' "Android cloud-backup rule"
require_text "$ANDROID_DATA_EXTRACTION_RULES" '<device-transfer>' "Android device-transfer rule"

require_text "$IOS_PRIVACY_MANIFEST" "<key>NSPrivacyTracking</key>" "iOS privacy tracking declaration"
require_text "$IOS_PRIVACY_MANIFEST" "<false/>" "iOS privacy tracking false value"
require_text "$IOS_PRIVACY_MANIFEST" "NSPrivacyCollectedDataTypes" "iOS collected data declaration"
require_text "$IOS_PRIVACY_MANIFEST" "NSPrivacyAccessedAPICategoryUserDefaults" "iOS UserDefaults required-reason category"
require_text "$IOS_PRIVACY_MANIFEST" "CA92.1" "iOS UserDefaults required reason"
require_text "$IOS_PROJECT_FILE" 'INFOPLIST_KEY_NSCameraUsageDescription = "PakFit can use a food photo' "iOS camera purpose string"
require_text "$IOS_PROJECT_FILE" 'INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "PakFit can use a food photo' "iOS photo library purpose string"

for disclosure_file in "$PRIVACY_POLICY" "$GOOGLE_PLAY_DATA_SAFETY" "$APP_STORE_PRIVACY" "$STORE_LISTING"; do
  require_text "$disclosure_file" "No account" "No-account disclosure"
  require_text "$disclosure_file" "No cloud sync" "No-cloud-sync disclosure"
  require_text "$disclosure_file" "No remote analytics" "No-remote-analytics disclosure"
done

require_text "$PRIVACY_POLICY" "no remote health data upload" "Privacy policy remote health upload disclosure"
require_text "$PRIVACY_POLICY" "Android uses an Android Keystore-backed encrypted payload" "Privacy policy Android encryption disclosure"
require_text "$PRIVACY_POLICY" "iOS stores the sensitive snapshot payload in Keychain" "Privacy policy iOS secure storage disclosure"
require_text "$PRIVACY_POLICY" "Food photo image bytes are not saved" "Privacy policy food-photo storage disclosure"
require_text "$PRIVACY_POLICY" "It does not diagnose, treat disease, prescribe therapy" "Privacy policy clinical boundary"

require_text "$GOOGLE_PLAY_DATA_SAFETY" "Collected by developer: No remote collection." "Google Play collection disclosure"
require_text "$GOOGLE_PLAY_DATA_SAFETY" "Shared with third parties: No app-driven sharing." "Google Play sharing disclosure"
require_text "$GOOGLE_PLAY_DATA_SAFETY" "Photos and videos: user-selected/captured food photo preview" "Google Play photo disclosure"
require_text "$GOOGLE_PLAY_DATA_SAFETY" "Saved Android snapshot payloads are encrypted" "Google Play local encryption disclosure"

require_text "$APP_STORE_PRIVACY" "NSPrivacyTracking" "App Store tracking disclosure"
require_text "$APP_STORE_PRIVACY" "NSPrivacyCollectedDataTypes" "App Store collected data disclosure"
require_text "$APP_STORE_PRIVACY" "No remote collection in this build" "App Store collection disclosure"
require_text "$APP_STORE_PRIVACY" "UserDefaults" "App Store UserDefaults disclosure"

require_text "$STORE_LISTING" "No account, ads, analytics SDK, push notifications, remote photo upload, or cloud sync is enabled in this build." "Store listing privacy summary"
require_text "$STORE_LISTING" "Privacy policy URL: TBD public hosted URL before public store submission." "Store listing public privacy-policy boundary"

require_absent "$PRIVACY_POLICY" "(tracking SDK enabled|sells? data|remote photo upload enabled|cloud sync enabled|analytics enabled|advertising SDK enabled)" "Unsupported privacy capability"
require_absent "$GOOGLE_PLAY_DATA_SAFETY" "(Collected by developer: Yes|Shared with third parties: Yes|analytics enabled|advertising SDK enabled)" "Unsupported Google Play data safety claim"
require_absent "$APP_STORE_PRIVACY" "(Data used to track users: Yes|tracking enabled|analytics SDK enabled|advertising enabled)" "Unsupported App Store privacy claim"

echo "Store privacy disclosure gate passed."
