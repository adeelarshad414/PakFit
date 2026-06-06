#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_MANIFEST="${ANDROID_MANIFEST:-$ROOT_DIR/app/src/main/AndroidManifest.xml}"

if [[ ! -f "$ANDROID_MANIFEST" ]]; then
  echo "Missing Android manifest: $ANDROID_MANIFEST" >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep not found; install rg to run the Android exported surface gate." >&2
  exit 1
fi

if rg -n '<(service|receiver|provider|activity-alias)\b' "$ANDROID_MANIFEST"; then
  echo "Android exported surface gate failed: services, receivers, providers, and activity aliases require a new security review before release." >&2
  exit 1
fi

EXPORTED_TRUE_COUNT="$(grep -c 'android:exported="true"' "$ANDROID_MANIFEST" | tr -d ' ')"
if [[ "$EXPORTED_TRUE_COUNT" != "1" ]]; then
  echo "Android manifest must expose exactly one component: the launcher MainActivity. Found exported=true count: $EXPORTED_TRUE_COUNT" >&2
  exit 1
fi

MAIN_ACTIVITY_BLOCK="$(
  awk '
    /<activity/ { in_activity = 1; block = "" }
    in_activity { block = block $0 "\n" }
    /<\/activity>/ {
      if (block ~ /android:name="\.MainActivity"/) {
        printf "%s", block
      }
      in_activity = 0
      block = ""
    }
  ' "$ANDROID_MANIFEST"
)"

if [[ -z "$MAIN_ACTIVITY_BLOCK" ]]; then
  echo "Android manifest must declare .MainActivity." >&2
  exit 1
fi
if [[ "$MAIN_ACTIVITY_BLOCK" != *'android:exported="true"'* ]]; then
  echo ".MainActivity must remain exported for the launcher entry point." >&2
  exit 1
fi
if [[ "$MAIN_ACTIVITY_BLOCK" != *'android.intent.action.MAIN'* ]]; then
  echo ".MainActivity must declare android.intent.action.MAIN." >&2
  exit 1
fi
if [[ "$MAIN_ACTIVITY_BLOCK" != *'android.intent.category.LAUNCHER'* ]]; then
  echo ".MainActivity must declare android.intent.category.LAUNCHER." >&2
  exit 1
fi

echo "Android exported surface gate passed."
