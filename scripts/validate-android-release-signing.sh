#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REQUIRED_ENV_VARS=(
  PAKFIT_RELEASE_STORE_FILE
  PAKFIT_RELEASE_STORE_PASSWORD
  PAKFIT_RELEASE_KEY_ALIAS
  PAKFIT_RELEASE_KEY_PASSWORD
)
SIGNING_GLOBS=(
  "*.jks"
  "*.keystore"
  "*.p12"
  "*.pfx"
  "*.pem"
  "*.key"
)

require_gitignore_pattern() {
  local pattern="$1"
  if ! grep -Fxq "$pattern" "$ROOT_DIR/.gitignore"; then
    echo ".gitignore must protect Android/iOS signing material pattern: $pattern" >&2
    exit 1
  fi
}

for pattern in "${SIGNING_GLOBS[@]}"; do
  require_gitignore_pattern "$pattern"
done

tracked_signing_files="$(
  git ls-files \
    | rg -i '\.(jks|keystore|p12|pfx|pem|key)$' \
    || true
)"
if [[ -n "$tracked_signing_files" ]]; then
  echo "Signing material must not be tracked in git:" >&2
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
    -o -type f \( -iname '*.jks' -o -iname '*.keystore' -o -iname '*.p12' -o -iname '*.pfx' -o -iname '*.pem' -o -iname '*.key' \) -print
)"
if [[ -n "$repo_signing_files" ]]; then
  echo "Signing material must stay outside the repository worktree:" >&2
  printf '%s\n' "$repo_signing_files" >&2
  exit 1
fi

if rg -n '(PAKFIT_RELEASE_STORE_PASSWORD|PAKFIT_RELEASE_KEY_PASSWORD)\s*[:=]\s*["'\''][^"'\'']{4,}["'\'']' README.md app ios specs scripts docs .github; then
  echo "Potential hardcoded Android release signing password detected." >&2
  exit 1
fi

provided_count=0
for env_var in "${REQUIRED_ENV_VARS[@]}"; do
  value="${!env_var:-}"
  if [[ -n "$value" ]]; then
    provided_count=$((provided_count + 1))
  fi
done

if [[ "$provided_count" != "0" && "$provided_count" != "${#REQUIRED_ENV_VARS[@]}" ]]; then
  echo "Android release signing requires all or none of: ${REQUIRED_ENV_VARS[*]}" >&2
  exit 1
fi

if [[ "$provided_count" == "${#REQUIRED_ENV_VARS[@]}" ]]; then
  store_file="$PAKFIT_RELEASE_STORE_FILE"
  if [[ "$store_file" != /* ]]; then
    echo "PAKFIT_RELEASE_STORE_FILE must be an absolute path outside the repository." >&2
    exit 1
  fi
  if [[ ! -f "$store_file" ]]; then
    echo "PAKFIT_RELEASE_STORE_FILE does not exist: $store_file" >&2
    exit 1
  fi
  if [[ ! -s "$store_file" ]]; then
    echo "PAKFIT_RELEASE_STORE_FILE is empty: $store_file" >&2
    exit 1
  fi
  canonical_store_dir="$(cd "$(dirname "$store_file")" && pwd -P)"
  canonical_store_file="$canonical_store_dir/$(basename "$store_file")"
  canonical_root="$(pwd -P)"
  case "$canonical_store_file" in
    "$canonical_root"/*)
      echo "PAKFIT_RELEASE_STORE_FILE must not live inside the repository: $canonical_store_file" >&2
      exit 1
      ;;
  esac
  case "$store_file" in
    *.jks|*.keystore|*.p12|*.pfx)
      ;;
    *)
      echo "PAKFIT_RELEASE_STORE_FILE should use a reviewed keystore/container extension: .jks, .keystore, .p12, or .pfx" >&2
      exit 1
      ;;
  esac
  echo "Android release signing hygiene gate passed: external signing environment configured."
else
  echo "Android release signing hygiene gate passed: unsigned local release mode."
fi
