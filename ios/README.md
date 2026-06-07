# PakFit iOS

PakFit iOS is the SwiftUI application path for the Pakistani health, fitness, workout, and nutrition product.

## What Is Included

- SwiftUI app with Dashboard, Tracker, Health, and Plan tabs.
- Tracker photo controls for choosing a food photo and capturing from camera on iPhone.
- Camera and photo library purpose strings scoped to food-photo calorie estimation.
- `Assets.xcassets/AppIcon.appiconset` for branded iOS app icon packaging.
- Local save, restore, clear, and export-preview actions backed by Keychain, UserDefaults metadata, and Codable snapshots.
- Consent and clinical-boundary gate before saving/exporting sensitive local health snapshots.
- Shared `PakFitCore` Swift module for calorie targets, Pakistani food catalog, food records, BMI, lab marker flags, online search URL generation, and food photo calorie estimates.
- Unit tests for the core engines under `ios/PakFitIOS/Tests`.
- Xcode project shell at `ios/PakFitIOS/PakFitIOS.xcodeproj`.
- Swift Package at `ios/PakFitIOS/Package.swift` for command-line core tests.
- Versioned iOS application handoff export through `scripts/export-ios-app-handoff.sh`.

## Test

```bash
cd ios/PakFitIOS
swift test
```

If the machine only has Apple Command Line Tools and `XCTest` is unavailable, run the no-XCTest smoke suite:

```bash
cd ios/PakFitIOS
swift run PakFitCoreSmokeTests
```

## Run In Xcode

Open `ios/PakFitIOS/PakFitIOS.xcodeproj`, select the `PakFitIOS` target, choose an iPhone simulator, and run.

This Codex environment currently has Apple Command Line Tools selected instead of full Xcode, so simulator builds require installing/selecting Xcode.app first.

## Export Handoff Artifact

From the repository root:

```bash
OUTPUT_DIR=/absolute/output/path bash scripts/export-ios-app-handoff.sh
```

The archive contains the Xcode project, Swift package, SwiftUI app source, shared Swift core, tests, AppIcon assets, manifest, and checksums. It is review evidence only; signed IPA, simulator `.app`, archive validation, TestFlight, and App Store Connect upload require full Xcode.app plus external Apple signing assets.

## Release Gates

The iOS path is checked by `scripts/validate-release.sh`, including Swift smoke tests, SwiftUI target compile, AppIcon validation, privacy manifest validation, permission purpose-string validation, network security validation, signing hygiene validation, iOS application handoff artifact validation, and food photo privacy validation.
