#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IOS_APP_SWIFT_DIR="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp"
IOS_CORE_SWIFT_DIR="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore"
IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"
IOS_PACKAGE_FILE="$ROOT_DIR/ios/PakFitIOS/Package.swift"

for required_path in "$IOS_APP_SWIFT_DIR" "$IOS_CORE_SWIFT_DIR" "$IOS_PROJECT_FILE" "$IOS_PACKAGE_FILE"; do
  if [[ ! -e "$required_path" ]]; then
    echo "Missing iOS network security input: $required_path" >&2
    exit 1
  fi
done

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep not found; install rg to run the iOS network security gate." >&2
  exit 1
fi

if rg -n 'http://' --glob '*.swift' "$IOS_APP_SWIFT_DIR" "$IOS_CORE_SWIFT_DIR"; then
  echo "iOS network security gate failed: runtime Swift app/core source must not contain cleartext http:// URLs." >&2
  exit 1
fi

ATS_CLEARTEXT_PATTERN='NSAllowsArbitraryLoads|NSAllowsArbitraryLoadsForMedia|NSAllowsArbitraryLoadsInWebContent|NSExceptionAllowsInsecureHTTPLoads|NSExceptionDomains'
if rg -n "$ATS_CLEARTEXT_PATTERN" "$IOS_PROJECT_FILE" "$IOS_PACKAGE_FILE" "$IOS_APP_SWIFT_DIR" "$IOS_CORE_SWIFT_DIR"; then
  echo "iOS network security gate failed: ATS cleartext opt-outs require a reviewed transport security spec." >&2
  exit 1
fi

if ! rg -q 'https://www\.google\.com/search' "$IOS_CORE_SWIFT_DIR"; then
  echo "iOS online calorie search must continue using an HTTPS search handoff." >&2
  exit 1
fi

echo "iOS network security gate passed."
