# PakFit iOS Application Handoff Artifact

The iOS application handoff artifact gives reviewers a versioned local package for the current SwiftUI app while signed Apple distribution remains external.

## Artifact

`scripts/export-ios-app-handoff.sh` creates:

- `PakFit-vX.Y.Z-ios-app-handoff.zip`
- `PakFitIOS-HANDOFF-MANIFEST.md`
- `PakFitIOS-HANDOFF-CHECKSUMS.txt`
- `Package.swift`
- `PakFitIOS.xcodeproj`
- `Sources`
- `Tests`
- `Assets.xcassets`
- iOS `README.md`

The exporter checks Android `versionName`/`versionCode` against iOS `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` before packaging the handoff archive.

## Validation

`scripts/validate-ios-app-handoff.sh` checks the export script, docs, spec, CI upload wiring, release-report wiring, signing hygiene boundary text, and a temporary archive export.

`scripts/validate-release.sh` runs the iOS application handoff artifact gate and exports the versioned local artifact before generating release evidence.

## Boundary

The current Codex machine has Command Line Tools selected and does not have full Xcode.app installed. The handoff artifact is therefore not a signed IPA, simulator `.app`, TestFlight build, App Store archive, or App Store Connect submission.

Full Xcode.app, Apple certificates, provisioning profiles, export options, App Store Connect access, and final device/simulator QA remain external before public iOS distribution.
