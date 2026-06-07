# Spec 061: iOS App Handoff Artifact Gate

## Objective

Add repeatable iOS application handoff artifact evidence for the SwiftUI app while the local machine lacks full Xcode.app and Apple signing assets.

## Functional Requirements

- Export a versioned `PakFit-vX.Y.Z-ios-app-handoff.zip` artifact into the ignored output folder.
- Include the Xcode project, Swift package manifest, SwiftUI app source, shared Swift core, tests, AppIcon assets, iOS README, handoff manifest, and per-file checksums.
- Verify Android and iOS version metadata match before exporting the iOS handoff artifact.
- Add CI upload coverage for the iOS handoff artifact.
- Add release evidence with artifact path, size, SHA-256, documentation checksum, and gate status.

## Non-Functional Requirements

- The handoff artifact must not include Apple certificates, provisioning profiles, export options, App Store credentials, or hardcoded signing settings.
- The workflow must clearly label signed IPA, simulator `.app`, App Store archive, TestFlight, and App Store Connect upload as external boundaries until full Xcode.app and signing assets are available.
- The validation gate must run locally and in CI without an iOS simulator, Apple developer account, or signing credentials.

## Acceptance Evidence

- `bash scripts/validate-ios-app-handoff.sh` exports and inspects a temporary handoff archive.
- `bash scripts/validate-release.sh` runs the iOS app handoff artifact gate and exports the local artifact before release evidence generation.
- `scripts/generate-release-report.sh` includes an iOS Application Handoff Artifact section.
- `.github/workflows/pakfit-ci.yml` exports and uploads the iOS handoff artifact.
- `docs/ios-app-handoff-artifact.md` documents the artifact contents and boundaries.

## Release Boundary

This spec proves the current iOS application source, project metadata, checksums, and release handoff posture. It does not prove a signed IPA, simulator `.app`, TestFlight build, App Store archive validation, or App Store Connect acceptance.
