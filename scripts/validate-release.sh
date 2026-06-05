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

echo "== Android unit tests and debug APK =="
"$GRADLE_CMD" testDebugUnitTest assembleDebug

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

echo "== English-only app source check =="
if command -v rg >/dev/null 2>&1; then
  if rg -n "Urdu|اردو|[\u0600-\u06FF]" README.md app/src ios; then
    echo "English-only app source check failed." >&2
    exit 1
  fi
  echo "== Secret-pattern smoke check =="
  if rg -n "(api[_-]?key|secret|token|password)\s*[:=]\s*['\"][^'\"]+" README.md app ios specs scripts .github; then
    echo "Potential hardcoded secret detected." >&2
    exit 1
  fi
else
  echo "ripgrep not found; install rg to run the source gates." >&2
  exit 1
fi

echo "PakFit release validation passed."
