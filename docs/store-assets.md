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

## Store Screenshot Previews

- `work/render_pakfit_screens.py` renders deterministic English-only PNG previews for key PakFit workflows.
- `scripts/validate-store-screenshots.sh` renders six phone screenshots plus one contact sheet and validates expected PNG dimensions and nonblank output.
- The default output path is `outputs/PakFit/screens`, which is ignored by git. Set `PAKFIT_SCREENSHOT_DIR` to export review assets into a shared folder.
- These previews are release-review evidence. Final Play Console and App Store Connect screenshots still need signed-binary/device review against each store's current screenshot requirements.

## Validation

Run `bash scripts/validate-app-icons.sh` and `bash scripts/validate-store-screenshots.sh` directly or through `bash scripts/validate-release.sh`.

The generator `scripts/generate-app-icons.mjs` can regenerate the iOS PNG icon set from the same PakFit mark if the icon dimensions need to be refreshed.
