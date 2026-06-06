#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_MANIFEST="${ANDROID_MANIFEST:-$ROOT_DIR/app/src/main/AndroidManifest.xml}"
ANDROID_SOURCE_DIR="$ROOT_DIR/app/src/main/java"
ANDROID_RES_DIR="$ROOT_DIR/app/src/main/res"

if [[ ! -f "$ANDROID_MANIFEST" ]]; then
  echo "Missing Android manifest: $ANDROID_MANIFEST" >&2
  exit 1
fi
if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep not found; install rg to run the Android network security gate." >&2
  exit 1
fi

if ! grep -q 'android:usesCleartextTraffic="false"' "$ANDROID_MANIFEST"; then
  echo "Android manifest must explicitly disable cleartext traffic." >&2
  exit 1
fi

ANDROID_CLEARTEXT_MATCHES="$(rg -n 'http://' "$ANDROID_SOURCE_DIR" "$ANDROID_RES_DIR" | grep -v 'http://schemas.android.com/apk/res/android' || true)"
if [[ -n "$ANDROID_CLEARTEXT_MATCHES" ]]; then
  echo "$ANDROID_CLEARTEXT_MATCHES"
  echo "Android network security gate failed: runtime app source/resources must not contain cleartext http:// URLs." >&2
  exit 1
fi

if ! rg -q 'https://www\.google\.com/search' "$ANDROID_SOURCE_DIR"; then
  echo "Android online calorie search must continue using an HTTPS search handoff." >&2
  exit 1
fi

echo "Android network security gate passed."
