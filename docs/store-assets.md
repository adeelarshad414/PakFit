# Store Asset Readiness

This document records the current committed PakFit app icon assets used by Android and iOS release validation.

## Android

- The Android manifest references `@mipmap/ic_launcher` and `@mipmap/ic_launcher_round`.
- `app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` defines an adaptive icon.
- `app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml` defines the round adaptive icon.
- `app/src/main/res/drawable/ic_launcher_foreground.xml` contains the PakFit foreground mark.
- `app/src/main/res/values/colors.xml` contains the PakFit icon background color.

## iOS

- `ios/PakFitIOS/Assets.xcassets/AppIcon.appiconset` contains the committed iPhone, iPad, and 1024x1024 marketing icon PNGs.
- The Xcode project sets `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` for Debug and Release.
- The Xcode project includes `Assets.xcassets` in the app resources phase.

## Validation

Run `bash scripts/validate-app-icons.sh` directly or through `bash scripts/validate-release.sh`.

The generator `scripts/generate-app-icons.mjs` can regenerate the iOS PNG icon set from the same PakFit mark if the icon dimensions need to be refreshed.
