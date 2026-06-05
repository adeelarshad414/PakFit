#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

METADATA_FILE="$ROOT_DIR/app/build/outputs/apk/debug/output-metadata.json"
APK_FILE="$ROOT_DIR/app/build/outputs/apk/debug/app-debug.apk"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/outputs/PakFit}"

if [[ ! -f "$APK_FILE" || ! -f "$METADATA_FILE" ]]; then
  echo "Debug APK metadata not found. Run scripts/validate-release.sh first." >&2
  exit 1
fi

VERSION_NAME="$(
  sed -n 's/.*"versionName": "\([^"]*\)".*/\1/p' "$METADATA_FILE" | head -1
)"

if [[ -z "$VERSION_NAME" ]]; then
  echo "Could not read versionName from $METADATA_FILE." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
DESTINATION="$OUTPUT_DIR/PakFit-v${VERSION_NAME}-debug.apk"
cp "$APK_FILE" "$DESTINATION"
echo "$DESTINATION"
