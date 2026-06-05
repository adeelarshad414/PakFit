# PakFit iOS

PakFit iOS is the SwiftUI application path for the Pakistani health, fitness, workout, and nutrition product.

## What Is Included

- SwiftUI app with Dashboard, Tracker, Health, and Plan tabs.
- Tracker photo controls for choosing a food photo and capturing from camera on iPhone.
- Local save, restore, clear, and export-preview actions backed by UserDefaults and Codable snapshots.
- Consent and clinical-boundary gate before saving/exporting sensitive local health snapshots.
- Shared `PakFitCore` Swift module for calorie targets, Pakistani food catalog, food records, BMI, lab marker flags, online search URL generation, and food photo calorie estimates.
- Unit tests for the core engines under `ios/PakFitIOS/Tests`.
- Xcode project shell at `ios/PakFitIOS/PakFitIOS.xcodeproj`.
- Swift Package at `ios/PakFitIOS/Package.swift` for command-line core tests.

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
