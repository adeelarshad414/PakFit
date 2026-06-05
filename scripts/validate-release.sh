#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -z "${JAVA_HOME:-}" && -d "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" ]]; then
  export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
fi

if [[ -z "${GRADLE_USER_HOME:-}" ]]; then
  export GRADLE_USER_HOME="$ROOT_DIR/.gradle-user-home"
fi

if [[ -z "${GRADLE_CMD:-}" ]]; then
  if [[ -x "/opt/homebrew/opt/gradle@8/bin/gradle" ]]; then
    GRADLE_CMD="/opt/homebrew/opt/gradle@8/bin/gradle"
  else
    GRADLE_CMD="gradle"
  fi
fi

if ! command -v "$GRADLE_CMD" >/dev/null 2>&1 && [[ ! -x "$GRADLE_CMD" ]]; then
  echo "Gradle not found. Set GRADLE_CMD or install Gradle 8." >&2
  exit 1
fi

echo "== Android unit tests, lint, debug APK, release APK, and release AAB =="
"$GRADLE_CMD" testDebugUnitTest lintDebug lintRelease assembleDebug assembleRelease bundleRelease

echo "== iOS Swift core smoke tests =="
if command -v swift >/dev/null 2>&1; then
  (
    cd "$ROOT_DIR/ios/PakFitIOS"
    swift run PakFitCoreSmokeTests
    swift build --target PakFitApp
  )
else
  echo "Swift not found; skipping iOS Swift validation." >&2
  exit 1
fi

echo "== iOS privacy manifest =="
PRIVACY_MANIFEST="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PrivacyInfo.xcprivacy"
if [[ ! -f "$PRIVACY_MANIFEST" ]]; then
  echo "Missing iOS privacy manifest: $PRIVACY_MANIFEST" >&2
  exit 1
fi
if command -v plutil >/dev/null 2>&1; then
  plutil -lint "$PRIVACY_MANIFEST"
fi
if ! grep -q "NSPrivacyAccessedAPICategoryUserDefaults" "$PRIVACY_MANIFEST"; then
  echo "Privacy manifest must declare UserDefaults required-reason API usage." >&2
  exit 1
fi
if ! grep -q "CA92.1" "$PRIVACY_MANIFEST"; then
  echo "Privacy manifest must declare CA92.1 for app-only UserDefaults storage." >&2
  exit 1
fi

echo "== Android backup privacy gate =="
ANDROID_MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
BACKUP_RULES="$ROOT_DIR/app/src/main/res/xml/backup_rules.xml"
DATA_EXTRACTION_RULES="$ROOT_DIR/app/src/main/res/xml/data_extraction_rules.xml"
if ! grep -q 'android:allowBackup="false"' "$ANDROID_MANIFEST"; then
  echo "Android Auto Backup must stay disabled for sensitive local health snapshots." >&2
  exit 1
fi
if ! grep -q 'android:fullBackupContent="@xml/backup_rules"' "$ANDROID_MANIFEST"; then
  echo "Android manifest must reference backup_rules.xml." >&2
  exit 1
fi
if ! grep -q 'android:dataExtractionRules="@xml/data_extraction_rules"' "$ANDROID_MANIFEST"; then
  echo "Android manifest must reference data_extraction_rules.xml." >&2
  exit 1
fi
for backup_file in "$BACKUP_RULES" "$DATA_EXTRACTION_RULES"; do
  if [[ ! -f "$backup_file" ]]; then
    echo "Missing Android backup privacy file: $backup_file" >&2
    exit 1
  fi
  if ! grep -q 'pakfit_local_snapshot.xml' "$backup_file"; then
    echo "Android backup privacy file must exclude pakfit_local_snapshot.xml: $backup_file" >&2
    exit 1
  fi
done
if ! grep -q '<cloud-backup' "$DATA_EXTRACTION_RULES"; then
  echo "Android data extraction rules must define cloud-backup behavior." >&2
  exit 1
fi
if ! grep -q '<device-transfer>' "$DATA_EXTRACTION_RULES"; then
  echo "Android data extraction rules must define device-transfer behavior." >&2
  exit 1
fi

echo "== English-only app source check =="
if command -v rg >/dev/null 2>&1; then
  if rg -n "Urdu|اردو|[\u0600-\u06FF]" README.md app/src ios; then
    echo "English-only app source check failed." >&2
    exit 1
  fi
  echo "== Secret-pattern smoke check =="
  if rg -n "(api[_-]?key|secret|token|password)\s*[:=]\s*['\"][^'\"]+" README.md app ios specs scripts docs .github; then
    echo "Potential hardcoded secret detected." >&2
    exit 1
  fi
else
  echo "ripgrep not found; install rg to run the source gates." >&2
  exit 1
fi

echo "== Release evidence report =="
bash scripts/generate-release-report.sh

echo "PakFit release validation passed."
