#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

EXPORT_SCRIPT="$ROOT_DIR/scripts/export-ios-app-handoff.sh"
RELEASE_SCRIPT="$ROOT_DIR/scripts/validate-release.sh"
REPORT_SCRIPT="$ROOT_DIR/scripts/generate-release-report.sh"
WORKFLOW_FILE="$ROOT_DIR/.github/workflows/pakfit-ci.yml"
SPEC_FILE="$ROOT_DIR/specs/061-ios-app-handoff-artifact-gate.md"
DOC_FILE="$ROOT_DIR/docs/ios-app-handoff-artifact.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"

for required_file in "$EXPORT_SCRIPT" "$RELEASE_SCRIPT" "$REPORT_SCRIPT" "$WORKFLOW_FILE" "$SPEC_FILE" "$DOC_FILE" "$STORE_LISTING"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing iOS app handoff gate input: $required_file" >&2
    exit 1
  fi
done

require_text() {
  local file="$1"
  local text="$2"
  local description="$3"
  if ! grep -Fq "$text" "$file"; then
    echo "$description is missing from $file: $text" >&2
    exit 1
  fi
}

bash -n "$EXPORT_SCRIPT"

require_text "$EXPORT_SCRIPT" "PakFitIOS-HANDOFF-MANIFEST.md" "handoff manifest export"
require_text "$EXPORT_SCRIPT" "PakFitIOS-HANDOFF-CHECKSUMS.txt" "handoff checksum export"
require_text "$EXPORT_SCRIPT" "PakFit-v\${ANDROID_VERSION_NAME}-ios-app-handoff.zip" "versioned iOS handoff zip export"
require_text "$EXPORT_SCRIPT" "SwiftUI app target" "iOS app target manifest copy"
require_text "$EXPORT_SCRIPT" "signed IPA" "signed IPA boundary"
require_text "$EXPORT_SCRIPT" "xcodebuild -version" "Xcode toolchain status capture"
require_text "$EXPORT_SCRIPT" "zip -qry" "zip archive creation"
require_text "$RELEASE_SCRIPT" "iOS app handoff artifact gate" "release gate wiring"
require_text "$REPORT_SCRIPT" "IOS_APP_HANDOFF_FILE" "release report iOS handoff artifact variable"
require_text "$REPORT_SCRIPT" "## iOS Application Handoff Artifact" "release report iOS handoff section"
require_text "$REPORT_SCRIPT" "iOS app handoff artifact gate" "release report gate evidence"
require_text "$WORKFLOW_FILE" "Export iOS app handoff artifact" "CI export step"
require_text "$WORKFLOW_FILE" "PakFit-ios-app-handoff" "CI upload artifact"
require_text "$SPEC_FILE" "iOS application handoff artifact" "iOS handoff spec title"
require_text "$DOC_FILE" "iOS application handoff artifact" "iOS handoff documentation"
require_text "$DOC_FILE" "full Xcode.app" "Xcode boundary documentation"
require_text "$STORE_LISTING" "iOS application handoff artifacts" "store listing artifact copy"

if grep -Eq "DEVELOPMENT_TEAM|PROVISIONING_PROFILE|CODE_SIGN_IDENTITY|\\.p12|\\.mobileprovision|ExportOptions\\.plist" "$EXPORT_SCRIPT"; then
  echo "iOS app handoff export must not reference signing identities, teams, provisioning profiles, or export options." >&2
  exit 1
fi

OUTPUT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pakfit-ios-handoff-validation.XXXXXX")"
cleanup() {
  rm -rf "$OUTPUT_DIR"
}
trap cleanup EXIT

ARCHIVE_PATH="$(OUTPUT_DIR="$OUTPUT_DIR" bash "$EXPORT_SCRIPT")"
if [[ ! -f "$ARCHIVE_PATH" ]]; then
  echo "iOS handoff archive was not created: $ARCHIVE_PATH" >&2
  exit 1
fi
if [[ ! -s "$ARCHIVE_PATH" ]]; then
  echo "iOS handoff archive is empty: $ARCHIVE_PATH" >&2
  exit 1
fi
if command -v unzip >/dev/null 2>&1; then
  ARCHIVE_LISTING="$(unzip -l "$ARCHIVE_PATH")"
  if ! grep -Fq "PakFitIOS-HANDOFF-MANIFEST.md" <<<"$ARCHIVE_LISTING"; then
    echo "iOS handoff archive is missing manifest." >&2
    exit 1
  fi
  if ! grep -Fq "PakFitIOS-HANDOFF-CHECKSUMS.txt" <<<"$ARCHIVE_LISTING"; then
    echo "iOS handoff archive is missing checksums." >&2
    exit 1
  fi
  if ! grep -Fq "PakFitIOS.xcodeproj/project.pbxproj" <<<"$ARCHIVE_LISTING"; then
    echo "iOS handoff archive is missing the Xcode project." >&2
    exit 1
  fi
fi

echo "iOS app handoff artifact gate passed."
