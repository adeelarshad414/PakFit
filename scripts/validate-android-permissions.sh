#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_MANIFEST="${ANDROID_MANIFEST:-$ROOT_DIR/app/src/main/AndroidManifest.xml}"
ALLOWED_ANDROID_PERMISSIONS=(
  "android.permission.INTERNET"
  "android.permission.CAMERA"
)

if [[ ! -f "$ANDROID_MANIFEST" ]]; then
  echo "Missing Android manifest: $ANDROID_MANIFEST" >&2
  exit 1
fi

DECLARED_ANDROID_PERMISSIONS=()
while IFS= read -r permission; do
  if [[ -n "$permission" ]]; then
    DECLARED_ANDROID_PERMISSIONS[${#DECLARED_ANDROID_PERMISSIONS[@]}]="$permission"
  fi
done < <(sed -n 's/.*<uses-permission[^>]*android:name="\([^"]*\)".*/\1/p' "$ANDROID_MANIFEST")

if [[ "${#DECLARED_ANDROID_PERMISSIONS[@]}" -eq 0 ]]; then
  echo "Android manifest must explicitly document the network/camera permission posture for online search and food photo capture." >&2
  exit 1
fi

for permission in "${DECLARED_ANDROID_PERMISSIONS[@]}"; do
  permission_allowed=false
  for allowed_permission in "${ALLOWED_ANDROID_PERMISSIONS[@]}"; do
    if [[ "$permission" == "$allowed_permission" ]]; then
      permission_allowed=true
      break
    fi
  done
  if [[ "$permission_allowed" != "true" ]]; then
    echo "Unexpected Android permission declared: $permission" >&2
    exit 1
  fi
done

for required_permission in "${ALLOWED_ANDROID_PERMISSIONS[@]}"; do
  if ! printf '%s\n' "${DECLARED_ANDROID_PERMISSIONS[@]}" | grep -qx "$required_permission"; then
    echo "Missing expected Android permission for current online/search-camera feature set: $required_permission" >&2
    exit 1
  fi
done

if ! grep -q 'android:name="android.hardware.camera"' "$ANDROID_MANIFEST"; then
  echo "Android camera feature must be declared when CAMERA permission is present." >&2
  exit 1
fi

if ! grep -q 'android:required="false"' "$ANDROID_MANIFEST"; then
  echo "Android camera hardware must stay optional so non-camera devices can install PakFit." >&2
  exit 1
fi

echo "Android permission privacy gate passed."
