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

REPORT_DIR="${REPORT_DIR:-$ROOT_DIR/outputs/PakFit/reports}"
DEPENDENCY_DIR="${DEPENDENCY_DIR:-$REPORT_DIR/dependencies}"
ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"
ROOT_BUILD_FILE="$ROOT_DIR/build.gradle.kts"
SETTINGS_FILE="$ROOT_DIR/settings.gradle.kts"
IOS_PACKAGE_FILE="$ROOT_DIR/ios/PakFitIOS/Package.swift"

VERSION_NAME="$(
  sed -n 's/.*versionName = "\([^"]*\)".*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"

if [[ -z "$VERSION_NAME" ]]; then
  echo "Could not read versionName from $ANDROID_BUILD_FILE." >&2
  exit 1
fi

mkdir -p "$DEPENDENCY_DIR"

ANDROID_DECLARED_FILE="$DEPENDENCY_DIR/PakFit-v${VERSION_NAME}-android-declared-dependencies.txt"
ANDROID_RELEASE_TREE_FILE="$DEPENDENCY_DIR/PakFit-v${VERSION_NAME}-android-releaseRuntimeClasspath.txt"
ANDROID_DEBUG_TREE_FILE="$DEPENDENCY_DIR/PakFit-v${VERSION_NAME}-android-debugRuntimeClasspath.txt"
ANDROID_TEST_TREE_FILE="$DEPENDENCY_DIR/PakFit-v${VERSION_NAME}-android-debugUnitTestRuntimeClasspath.txt"
IOS_DEPENDENCY_FILE="$DEPENDENCY_DIR/PakFit-v${VERSION_NAME}-ios-swift-package-dependencies.txt"
REPORT_FILE="$REPORT_DIR/PakFit-v${VERSION_NAME}-dependency-inventory.md"

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

find_dynamic_dependency_declarations() {
  grep -nE '(latest\.|SNAPSHOT|:[^"]*[+]"|version[[:space:]]*=[[:space:]]*"[+]")' \
    "$ROOT_BUILD_FILE" \
    "$ANDROID_BUILD_FILE" \
    "$SETTINGS_FILE" \
    "$IOS_PACKAGE_FILE" || true
}

DYNAMIC_DEPENDENCIES="$(find_dynamic_dependency_declarations)"
if [[ -n "$DYNAMIC_DEPENDENCIES" ]]; then
  echo "Dynamic or SNAPSHOT dependency declarations are not allowed in release builds:" >&2
  echo "$DYNAMIC_DEPENDENCIES" >&2
  exit 1
fi

grep -nE '^[[:space:]]*(implementation|debugImplementation|testImplementation)\("' "$ANDROID_BUILD_FILE" \
  | sed 's/^[[:space:]]*//' > "$ANDROID_DECLARED_FILE"

"$GRADLE_CMD" :app:dependencies --configuration releaseRuntimeClasspath > "$ANDROID_RELEASE_TREE_FILE"
"$GRADLE_CMD" :app:dependencies --configuration debugRuntimeClasspath > "$ANDROID_DEBUG_TREE_FILE"
"$GRADLE_CMD" :app:dependencies --configuration debugUnitTestRuntimeClasspath > "$ANDROID_TEST_TREE_FILE"

if grep -q '\.package(' "$IOS_PACKAGE_FILE"; then
  grep -n '\.package(' "$IOS_PACKAGE_FILE" > "$IOS_DEPENDENCY_FILE"
else
  echo "No external Swift package dependencies declared." > "$IOS_DEPENDENCY_FILE"
fi

ANDROID_DECLARED_COUNT="$(wc -l < "$ANDROID_DECLARED_FILE" | tr -d ' ')"
ANDROID_RELEASE_TREE_SHA="$(sha256_file "$ANDROID_RELEASE_TREE_FILE")"
ANDROID_DEBUG_TREE_SHA="$(sha256_file "$ANDROID_DEBUG_TREE_FILE")"
ANDROID_TEST_TREE_SHA="$(sha256_file "$ANDROID_TEST_TREE_FILE")"
IOS_DEPENDENCY_SHA="$(sha256_file "$IOS_DEPENDENCY_FILE")"
REPORT_TIME_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "# PakFit Dependency Inventory"
  echo
  echo "- Generated UTC: $REPORT_TIME_UTC"
  echo "- Version name: $VERSION_NAME"
  echo "- Dynamic/SNAPSHOT dependency gate: passed"
  echo "- Android declared dependency count: $ANDROID_DECLARED_COUNT"
  echo "- Android declared dependency file: $ANDROID_DECLARED_FILE"
  echo "- Android release runtime classpath: $ANDROID_RELEASE_TREE_FILE"
  echo "- Android release runtime classpath SHA-256: $ANDROID_RELEASE_TREE_SHA"
  echo "- Android debug runtime classpath: $ANDROID_DEBUG_TREE_FILE"
  echo "- Android debug runtime classpath SHA-256: $ANDROID_DEBUG_TREE_SHA"
  echo "- Android test runtime classpath: $ANDROID_TEST_TREE_FILE"
  echo "- Android test runtime classpath SHA-256: $ANDROID_TEST_TREE_SHA"
  echo "- iOS Swift package dependency file: $IOS_DEPENDENCY_FILE"
  echo "- iOS Swift package dependency SHA-256: $IOS_DEPENDENCY_SHA"
  echo
  echo "## Android Plugins"
  echo
  grep -nE 'id\(".*"\) version' "$ROOT_BUILD_FILE" || echo "No versioned root plugins detected."
  echo
  echo "## Android Declared Dependencies"
  echo
  cat "$ANDROID_DECLARED_FILE"
  echo
  echo "## iOS Swift Package Dependencies"
  echo
  cat "$IOS_DEPENDENCY_FILE"
  echo
  echo "## Boundary"
  echo
  echo "- This is an offline dependency inventory and reproducibility gate."
  echo "- Public vulnerability advisory checks still require a network-enabled scanner or dependency review service."
} > "$REPORT_FILE"

echo "$REPORT_FILE"
