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
  if [[ -x "$ROOT_DIR/gradlew" ]]; then
    GRADLE_CMD="$ROOT_DIR/gradlew"
  elif [[ -x "/opt/homebrew/opt/gradle@8/bin/gradle" ]]; then
    GRADLE_CMD="/opt/homebrew/opt/gradle@8/bin/gradle"
  else
    GRADLE_CMD="gradle"
  fi
fi

if ! command -v "$GRADLE_CMD" >/dev/null 2>&1 && [[ ! -x "$GRADLE_CMD" ]]; then
  echo "Gradle not found. Set GRADLE_CMD or install Gradle 8." >&2
  exit 1
fi

GRADLE_VERIFICATION_ARGS=(--dependency-verification strict)

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

echo "== Gradle Wrapper integrity gate =="
WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
EXPECTED_WRAPPER_JAR_SHA256="7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172"
EXPECTED_DISTRIBUTION_SHA256="6f74b601422d6d6fc4e1f9a1ab6522f642c2fdcbc15ae33ebd30ba3d7198e854"
if [[ ! -x "$ROOT_DIR/gradlew" ]]; then
  echo "Missing executable Gradle Wrapper: $ROOT_DIR/gradlew" >&2
  exit 1
fi
if [[ ! -f "$WRAPPER_PROPERTIES" || ! -f "$WRAPPER_JAR" ]]; then
  echo "Missing Gradle Wrapper files." >&2
  exit 1
fi
if ! grep -q "gradle-8.14.5-bin.zip" "$WRAPPER_PROPERTIES"; then
  echo "Gradle Wrapper must pin Gradle 8.14.5." >&2
  exit 1
fi
if ! grep -q "distributionSha256Sum=$EXPECTED_DISTRIBUTION_SHA256" "$WRAPPER_PROPERTIES"; then
  echo "Gradle Wrapper distribution SHA-256 does not match expected Gradle 8.14.5 checksum." >&2
  exit 1
fi
if [[ "$(sha256_file "$WRAPPER_JAR")" != "$EXPECTED_WRAPPER_JAR_SHA256" ]]; then
  echo "Gradle Wrapper JAR checksum does not match the committed expected value." >&2
  exit 1
fi

echo "== Gradle dependency verification gate =="
VERIFICATION_METADATA="$ROOT_DIR/gradle/verification-metadata.xml"
if [[ ! -f "$VERIFICATION_METADATA" ]]; then
  echo "Missing Gradle dependency verification metadata: $VERIFICATION_METADATA" >&2
  exit 1
fi
if ! grep -q "<verify-metadata>true</verify-metadata>" "$VERIFICATION_METADATA"; then
  echo "Gradle dependency verification must verify metadata artifacts." >&2
  exit 1
fi
if ! grep -q "<sha256 " "$VERIFICATION_METADATA"; then
  echo "Gradle dependency verification metadata must include SHA-256 checksums." >&2
  exit 1
fi

echo "== Cross-platform version alignment gate =="
bash scripts/validate-version-alignment.sh

echo "== App identity metadata gate =="
bash scripts/validate-app-identity.sh

echo "== Store listing and release notes gate =="
bash scripts/validate-store-listing.sh

echo "== Store screenshot asset gate =="
bash scripts/validate-store-screenshots.sh

echo "== App icon asset gate =="
bash scripts/validate-app-icons.sh

echo "== Platform compatibility gate =="
bash scripts/validate-platform-compatibility.sh

echo "== Android build toolchain gate =="
bash scripts/validate-android-build-toolchain.sh

echo "== Android release signing hygiene gate =="
bash scripts/validate-android-release-signing.sh

echo "== Android unit tests, lint, debug APK, release APK, and release AAB =="
"$GRADLE_CMD" "${GRADLE_VERIFICATION_ARGS[@]}" testDebugUnitTest lintDebug lintRelease assembleDebug assembleRelease bundleRelease

echo "== Android artifact version metadata gate =="
bash scripts/validate-version-alignment.sh --include-built-metadata

echo "== Dependency inventory gate =="
GRADLE_CMD="$GRADLE_CMD" bash scripts/generate-dependency-inventory.sh

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

echo "== iOS permission privacy gate =="
bash scripts/validate-ios-permission-privacy.sh

echo "== iOS network security gate =="
bash scripts/validate-ios-network-security.sh

echo "== iOS signing hygiene gate =="
bash scripts/validate-ios-signing-hygiene.sh

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

echo "== Android permission privacy gate =="
bash scripts/validate-android-permissions.sh

echo "== Android exported surface gate =="
bash scripts/validate-android-exported-surface.sh

echo "== Android network security gate =="
bash scripts/validate-android-network-security.sh

echo "== Food photo privacy gate =="
bash scripts/validate-photo-privacy.sh

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
