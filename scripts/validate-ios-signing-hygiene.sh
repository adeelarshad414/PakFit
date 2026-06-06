#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"
SIGNING_PATTERNS=(
  "*.p12"
  "*.pfx"
  "*.pem"
  "*.key"
  "*.cer"
  "*.certSigningRequest"
  "*.csr"
  "*.developerprofile"
  "*.mobileprovision"
  "*.provisionprofile"
  "*.ipa"
  "*.xcarchive"
  "ExportOptions.plist"
)

if [[ ! -f "$IOS_PROJECT_FILE" ]]; then
  echo "Missing iOS Xcode project file: $IOS_PROJECT_FILE" >&2
  exit 1
fi

require_gitignore_pattern() {
  local pattern="$1"
  if ! grep -Fxq "$pattern" "$ROOT_DIR/.gitignore"; then
    echo ".gitignore must protect iOS signing material pattern: $pattern" >&2
    exit 1
  fi
}

for pattern in "${SIGNING_PATTERNS[@]}"; do
  require_gitignore_pattern "$pattern"
done

tracked_signing_files="$(
  git ls-files \
    | rg -i '(\.(p12|pfx|pem|key|cer|certSigningRequest|csr|developerprofile|mobileprovision|provisionprofile|ipa|xcarchive)$|(^|/)ExportOptions\.plist$)' \
    || true
)"
if [[ -n "$tracked_signing_files" ]]; then
  echo "iOS signing material must not be tracked in git:" >&2
  printf '%s\n' "$tracked_signing_files" >&2
  exit 1
fi

repo_signing_files="$(
  find "$ROOT_DIR" \
    \( -path "$ROOT_DIR/.git" \
      -o -path "$ROOT_DIR/.gradle" \
      -o -path "$ROOT_DIR/.gradle-user-home" \
      -o -path "$ROOT_DIR/app/build" \
      -o -path "$ROOT_DIR/build" \
      -o -path "$ROOT_DIR/ios/PakFitIOS/.build" \
      -o -path "$ROOT_DIR/outputs" \) -prune \
    -o -type f \( -iname '*.p12' -o -iname '*.pfx' -o -iname '*.pem' -o -iname '*.key' -o -iname '*.cer' -o -iname '*.certSigningRequest' -o -iname '*.csr' -o -iname '*.developerprofile' -o -iname '*.mobileprovision' -o -iname '*.provisionprofile' -o -iname '*.ipa' -o -iname '*.xcarchive' -o -iname 'ExportOptions.plist' \) -print
)"
if [[ -n "$repo_signing_files" ]]; then
  echo "iOS signing material must stay outside the repository worktree:" >&2
  printf '%s\n' "$repo_signing_files" >&2
  exit 1
fi

if rg -n '(APPLE_CERTIFICATE|APP_STORE_CONNECT|ASC_|MATCH_PASSWORD|FASTLANE_PASSWORD|FASTLANE_SESSION|IOS_SIGNING|PROVISIONING_PROFILE|DEVELOPMENT_TEAM)\s*[:=]\s*["'\''][^"'\'']{4,}["'\'']' README.md app ios specs scripts docs .github; then
  echo "Potential hardcoded iOS signing or App Store credential detected." >&2
  exit 1
fi

development_team_values="$(
  sed -n 's/.*DEVELOPMENT_TEAM = \(.*\);.*/\1/p' "$IOS_PROJECT_FILE" | sed 's/^"//; s/"$//' | sed '/^[[:space:]]*$/d' | sort -u
)"
if [[ -n "$development_team_values" ]]; then
  echo "iOS DEVELOPMENT_TEAM must remain unset in source until signing assets are reviewed externally. Found:" >&2
  printf '%s\n' "$development_team_values" >&2
  exit 1
fi

if rg -n 'PROVISIONING_PROFILE_SPECIFIER|CODE_SIGN_IDENTITY|DEVELOPMENT_TEAM = [A-Z0-9]{10}|CODE_SIGN_STYLE = Manual' "$IOS_PROJECT_FILE"; then
  echo "iOS project must not pin provisioning profiles, signing identities, teams, or manual signing in source." >&2
  exit 1
fi

echo "iOS signing hygiene gate passed: signing assets remain external."
