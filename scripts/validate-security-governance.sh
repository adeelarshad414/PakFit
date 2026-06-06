#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SECURITY_POLICY="$ROOT_DIR/SECURITY.md"
CODEOWNERS="$ROOT_DIR/.github/CODEOWNERS"
SECURITY_DOC="$ROOT_DIR/docs/security-governance.md"
WORKFLOW="$ROOT_DIR/.github/workflows/pakfit-ci.yml"
ANDROID_BUILD_FILE="$ROOT_DIR/app/build.gradle.kts"

for required_file in "$SECURITY_POLICY" "$CODEOWNERS" "$SECURITY_DOC" "$WORKFLOW" "$ANDROID_BUILD_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing security governance input: $required_file" >&2
    exit 1
  fi
done

require_text() {
  local file="$1"
  local text="$2"
  local description="$3"
  if ! grep -Fq "$text" "$file"; then
    echo "$description is missing from $file: $text" >&2
    exit 1
  fi
}

VERSION_NAME="$(
  sed -n 's/.*versionName = "\([^"]*\)".*/\1/p' "$ANDROID_BUILD_FILE" | head -1
)"
VERSION_MINOR="${VERSION_NAME%.*}.x"
if [[ -z "$VERSION_NAME" || "$VERSION_MINOR" == "$VERSION_NAME" ]]; then
  echo "Could not derive release version from $ANDROID_BUILD_FILE." >&2
  exit 1
fi

require_text "$SECURITY_POLICY" "# Security Policy" "Security policy title"
require_text "$SECURITY_POLICY" "## Supported Versions" "Supported versions section"
require_text "$SECURITY_POLICY" "| $VERSION_MINOR | Current local release evidence |" "Current supported version row"
require_text "$SECURITY_POLICY" "Please do not report sensitive vulnerabilities" "Sensitive public-reporting warning"
require_text "$SECURITY_POLICY" "GitHub private vulnerability reporting" "Private reporting boundary"
require_text "$SECURITY_POLICY" "health-data privacy issues" "Health-data vulnerability scope"
require_text "$SECURITY_POLICY" "signing-key issues" "Signing-key vulnerability scope"
require_text "$SECURITY_POLICY" "Clinical Safety Boundary" "Clinical safety boundary"
require_text "$SECURITY_DOC" "scripts/validate-security-governance.sh" "Security governance validation docs"

for owner_pattern in \
  "* @adeelarshad414" \
  "/.github/ @adeelarshad414" \
  "/app/ @adeelarshad414" \
  "/ios/ @adeelarshad414" \
  "/scripts/ @adeelarshad414" \
  "/gradle/ @adeelarshad414" \
  "/docs/ @adeelarshad414" \
  "/specs/ @adeelarshad414" \
  "/SECURITY.md @adeelarshad414"; do
  require_text "$CODEOWNERS" "$owner_pattern" "CODEOWNERS coverage"
done

require_text "$WORKFLOW" "permissions:" "Workflow permissions block"
require_text "$WORKFLOW" "  contents: read" "Workflow read-only contents permission"
if rg -n "pull_request_target|contents: write|actions: write|security-events: write|id-token: write" "$WORKFLOW"; then
  echo "CI workflow must not use high-risk triggers or write permissions without a reviewed CI security spec." >&2
  exit 1
fi

if rg -n "(security@|vulnerability@|bug bounty|bounty|public issue for sensitive)" "$SECURITY_POLICY" "$SECURITY_DOC"; then
  echo "Security policy must not advertise unreviewed public contacts, bounty terms, or public sensitive issue reporting." >&2
  exit 1
fi

echo "Security governance gate passed."
