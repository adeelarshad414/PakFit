#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DEPENDABOT_CONFIG="$ROOT_DIR/.github/dependabot.yml"

if [[ ! -f "$DEPENDABOT_CONFIG" ]]; then
  echo "Missing Dependabot configuration: $DEPENDABOT_CONFIG" >&2
  exit 1
fi

require_text() {
  local text="$1"
  local description="$2"
  if ! grep -Fq "$text" "$DEPENDABOT_CONFIG"; then
    echo "$description is missing from $DEPENDABOT_CONFIG: $text" >&2
    exit 1
  fi
}

require_text "version: 2" "Dependabot schema version"
require_text 'package-ecosystem: "gradle"' "Gradle dependency updates"
require_text 'directory: "/"' "Root dependency directory"
require_text 'package-ecosystem: "swift"' "Swift Package Manager dependency updates"
require_text 'directory: "/ios/PakFitIOS"' "Swift package directory"
require_text 'package-ecosystem: "github-actions"' "GitHub Actions dependency updates"
require_text 'timezone: "Asia/Karachi"' "Pakistani release-ops timezone"
require_text 'open-pull-requests-limit: 5' "Dependabot pull-request limit"
require_text '"dependencies"' "Dependency label"
require_text '"android"' "Android dependency label"
require_text '"ios"' "iOS dependency label"
require_text '"ci"' "CI dependency label"

ecosystem_count="$(grep -c 'package-ecosystem:' "$DEPENDABOT_CONFIG" | tr -d ' ')"
if [[ "$ecosystem_count" != "3" ]]; then
  echo "Dependabot must cover exactly the current three dependency surfaces: Gradle, SwiftPM, and GitHub Actions. Found: $ecosystem_count" >&2
  exit 1
fi

weekly_count="$(grep -c 'interval: "weekly"' "$DEPENDABOT_CONFIG" | tr -d ' ')"
if [[ "$weekly_count" != "3" ]]; then
  echo "Every Dependabot ecosystem must use a weekly schedule. Found weekly schedules: $weekly_count" >&2
  exit 1
fi

if grep -Eq 'allow:|ignore:|vendor:|insecure-external-code-execution' "$DEPENDABOT_CONFIG"; then
  echo "Dependabot config must not suppress or weaken dependency update coverage without a reviewed supply-chain spec." >&2
  exit 1
fi

echo "Dependency advisory configuration gate passed."
