# PakFit v0.46.0 Release Notes

PakFit version 0.46.0 build 46 advances production release readiness with repeatable Android and iOS local artifact evidence.

## Added

- Versioned iOS application handoff archive export for the SwiftUI app, shared Swift core, tests, Xcode project, AppIcon assets, manifest, and checksums.
- iOS app handoff artifact release gate with temporary archive validation and signing-boundary checks.
- Release evidence report coverage for iOS handoff artifact path, size, SHA-256, documentation checksum, and gate status.
- CI upload coverage for the iOS handoff artifact alongside Android APK/AAB evidence.

## Boundary

The iOS handoff archive is local review evidence. Signed IPA, simulator `.app`, TestFlight, App Store archive validation, and App Store Connect upload still require full Xcode.app plus external Apple signing assets.
