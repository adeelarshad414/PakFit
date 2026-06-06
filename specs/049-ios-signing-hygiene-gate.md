# Spec 049 - iOS Signing Hygiene Gate

## Objective

Add a local release gate that keeps iOS signing material and App Store credentials out of source control, validates the current unsigned/local Xcode project posture, and records iOS signing hygiene in release evidence.

## Functional Requirements

- Ignore common iOS signing material and export option files in `.gitignore`.
- Fail if iOS signing material is tracked by git.
- Fail if iOS signing material is placed anywhere inside the repository worktree.
- Fail if source/docs/scripts contain hardcoded iOS signing or App Store credential values.
- Fail if the Xcode project pins `DEVELOPMENT_TEAM`, provisioning profiles, signing identities, or manual signing mode in source.
- Pass when signing assets remain external and local Swift validation remains unsigned.
- Include the gate in local release validation, CI, and release evidence reports.
- Bump Android and iOS version metadata for the generated release artifacts.

## Non-Functional Requirements

- The gate must not echo secrets or require App Store Connect access.
- The gate must run without backend services, analytics keys, cloud health data, Xcode archive signing, or Apple credentials.
- The gate must not commit or generate certificates, provisioning profiles, export option files, or keychain material.

## Acceptance Evidence

- `scripts/validate-ios-signing-hygiene.sh` passes in local unsigned mode.
- `.gitignore` protects common iOS signing material extensions and `ExportOptions.plist`.
- `scripts/validate-release.sh` runs the iOS signing hygiene gate.
- GitHub Actions runs the iOS signing hygiene gate.
- `scripts/generate-release-report.sh` records the iOS signing hygiene gate status.
- Android and iOS version metadata are bumped to `0.34.0` build `34`.
