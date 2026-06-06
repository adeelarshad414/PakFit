#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ROOT_BUILD_FILE="$ROOT_DIR/build.gradle.kts"
APP_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
GRADLE_PROPERTIES="$ROOT_DIR/gradle.properties"
WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"

for required_file in "$ROOT_BUILD_FILE" "$APP_BUILD_FILE" "$GRADLE_PROPERTIES" "$WRAPPER_PROPERTIES"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing Android build toolchain input: $required_file" >&2
    exit 1
  fi
done

AGP_VERSION="$(
  sed -n 's/.*id("com.android.application") version "\([^"]*\)".*/\1/p' "$ROOT_BUILD_FILE" | head -1
)"
COMPILE_SDK="$(
  sed -n 's/.*compileSdk = \([0-9][0-9]*\).*/\1/p' "$APP_BUILD_FILE" | head -1
)"

if [[ -z "$AGP_VERSION" || -z "$COMPILE_SDK" ]]; then
  echo "Could not read Android Gradle Plugin version or compileSdk." >&2
  exit 1
fi

IFS=. read -r agp_major agp_minor agp_patch <<EOF_AGP
$AGP_VERSION
EOF_AGP
agp_major="${agp_major:-0}"
agp_minor="${agp_minor:-0}"
agp_patch="${agp_patch:-0}"

if [[ "$agp_major" -lt 8 ]] || [[ "$agp_major" -eq 8 && "$agp_minor" -lt 6 ]]; then
  echo "Android Gradle Plugin must be 8.6.0 or higher for compileSdk 35 support. Found: $AGP_VERSION" >&2
  exit 1
fi

if [[ "$COMPILE_SDK" -ge 35 && "$agp_major" -eq 8 && "$agp_minor" -lt 6 ]]; then
  echo "compileSdk $COMPILE_SDK requires an Android Gradle Plugin line that supports API 35. Found: $AGP_VERSION" >&2
  exit 1
fi

if grep -q 'android.suppressUnsupportedCompileSdk' "$GRADLE_PROPERTIES"; then
  echo "Do not suppress unsupported compileSdk warnings; upgrade the Android Gradle Plugin instead." >&2
  exit 1
fi

if ! grep -q 'gradle-8.14.5-bin.zip' "$WRAPPER_PROPERTIES"; then
  echo "Gradle Wrapper must remain on the verified Gradle 8.14.5 distribution for this toolchain slice." >&2
  exit 1
fi

echo "Android build toolchain gate passed."
