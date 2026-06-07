#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LOG_DIR="$ROOT_DIR/logs"
PID_FILE="$LOG_DIR/dev-pids.txt"
GRADLE_LOG="$LOG_DIR/android-dev.log"
SWIFT_LOG="$LOG_DIR/ios-dev.log"
SUMMARY_LOG="$LOG_DIR/dev-start-summary.log"

mkdir -p "$LOG_DIR"
: > "$PID_FILE"
: > "$SUMMARY_LOG"

if [[ -z "${JAVA_HOME:-}" && -d "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" ]]; then
  export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
fi

if [[ -z "${GRADLE_USER_HOME:-}" && -d "/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle" ]]; then
  export GRADLE_USER_HOME="/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/work/pakfit-gradle"
fi

if [[ -z "${ANDROID_HOME:-}" && -d "/opt/homebrew/share/android-commandlinetools" ]]; then
  export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
fi
if [[ -z "${ANDROID_SDK_ROOT:-}" && -n "${ANDROID_HOME:-}" ]]; then
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
fi

require_command() {
  local command_name="$1"
  local install_hint="$2"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    echo "Install hint: $install_hint" >&2
    exit 1
  fi
}

require_path() {
  local path="$1"
  local message="$2"
  if [[ ! -e "$path" ]]; then
    echo "$message: $path" >&2
    exit 1
  fi
}

require_command java "Install JDK 17, for example Temurin 17 or Homebrew openjdk@17."
require_command bash "Install bash."
require_command rg "Install ripgrep: https://github.com/BurntSushi/ripgrep"
require_path "$ROOT_DIR/gradlew" "Missing Gradle wrapper"
require_path "$ROOT_DIR/ios/PakFitIOS/Package.swift" "Missing Swift package"

if [[ -f "$ROOT_DIR/.env.example" && ! -f "$ROOT_DIR/.env" ]]; then
  cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
fi

run_and_log() {
  local label="$1"
  local log_file="$2"
  shift 2
  echo "== $label ==" | tee -a "$SUMMARY_LOG"
  if "$@" >"$log_file" 2>&1; then
    echo "$label: passed" | tee -a "$SUMMARY_LOG"
  else
    echo "$label: failed. See $log_file" | tee -a "$SUMMARY_LOG" >&2
    tail -80 "$log_file" >&2 || true
    exit 1
  fi
}

if [[ "${PAKFIT_DEV_SKIP_BUILDS:-0}" != "1" ]]; then
  run_and_log "Android unit tests and debug APK" "$GRADLE_LOG" \
    "$ROOT_DIR/gradlew" --dependency-verification strict testDebugUnitTest assembleDebug

  if command -v swift >/dev/null 2>&1; then
    run_and_log "iOS Swift smoke and app compile" "$SWIFT_LOG" \
      bash -c 'cd ios/PakFitIOS && swift run PakFitCoreSmokeTests && swift build --target PakFitApp'
  else
    echo "iOS Swift smoke and app compile: skipped; swift not found" | tee -a "$SUMMARY_LOG"
  fi
else
  echo "Builds skipped because PAKFIT_DEV_SKIP_BUILDS=1" | tee -a "$SUMMARY_LOG"
fi

DEBUG_APK="$ROOT_DIR/app/build/outputs/apk/debug/app-debug.apk"
IOS_HANDOFF="$ROOT_DIR/outputs/PakFit/PakFit-v$(sed -n 's/.*versionName = "\([^"]*\)".*/\1/p' app/build.gradle.kts | head -1)-ios-app-handoff.zip"

cat <<EOF
PakFit developer start summary

+-----------------------------+-----------------------------------------------+--------+
| Service                     | URL / artifact                                | Status |
+-----------------------------+-----------------------------------------------+--------+
| Backend API                 | none - local native app only                  | n/a    |
| Frontend web                | none - native Android and iOS                 | n/a    |
| Android debug APK           | $DEBUG_APK | ready  |
| iOS Swift package           | ios/PakFitIOS                                 | ready  |
+-----------------------------+-----------------------------------------------+--------+

No persistent services were started, so $PID_FILE is intentionally empty.
Logs:
- Android: $GRADLE_LOG
- iOS: $SWIFT_LOG

Demo personas and scenario credentials are listed in docs/TEST_CREDENTIALS.csv.
Use bash scripts/dev-stop.sh to clean up tracked processes and verify known ports.
EOF
