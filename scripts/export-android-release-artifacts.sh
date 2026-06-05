#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

RELEASE_METADATA_FILE="$ROOT_DIR/app/build/outputs/apk/release/output-metadata.json"
RELEASE_AAB_FILE="$ROOT_DIR/app/build/outputs/bundle/release/app-release.aab"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/outputs/PakFit}"

metadata_value() {
  local file="$1"
  local key="$2"
  sed -n "s/.*\"$key\": \"\\([^\"]*\\)\".*/\\1/p" "$file" | head -1
}

if [[ ! -f "$RELEASE_METADATA_FILE" ]]; then
  echo "Release APK metadata not found. Run scripts/validate-release.sh first." >&2
  exit 1
fi

VERSION_NAME="$(metadata_value "$RELEASE_METADATA_FILE" versionName)"
RELEASE_APK_NAME="$(metadata_value "$RELEASE_METADATA_FILE" outputFile)"
RELEASE_APK_FILE="$ROOT_DIR/app/build/outputs/apk/release/$RELEASE_APK_NAME"

if [[ -z "$VERSION_NAME" || -z "$RELEASE_APK_NAME" ]]; then
  echo "Could not read release metadata from $RELEASE_METADATA_FILE." >&2
  exit 1
fi

if [[ ! -f "$RELEASE_APK_FILE" ]]; then
  echo "Release APK not found: $RELEASE_APK_FILE. Run scripts/validate-release.sh first." >&2
  exit 1
fi

if [[ ! -f "$RELEASE_AAB_FILE" ]]; then
  echo "Release AAB not found: $RELEASE_AAB_FILE. Run scripts/validate-release.sh first." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

APK_SUFFIX="release"
if [[ "$RELEASE_APK_NAME" == *unsigned* ]]; then
  APK_SUFFIX="release-unsigned"
fi

APK_DESTINATION="$OUTPUT_DIR/PakFit-v${VERSION_NAME}-${APK_SUFFIX}.apk"
AAB_DESTINATION="$OUTPUT_DIR/PakFit-v${VERSION_NAME}-release.aab"

cp "$RELEASE_APK_FILE" "$APK_DESTINATION"
cp "$RELEASE_AAB_FILE" "$AAB_DESTINATION"

echo "$APK_DESTINATION"
echo "$AAB_DESTINATION"
