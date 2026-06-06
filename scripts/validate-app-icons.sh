#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
ANDROID_ICON="$ROOT_DIR/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"
ANDROID_ROUND_ICON="$ROOT_DIR/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml"
ANDROID_FOREGROUND="$ROOT_DIR/app/src/main/res/drawable/ic_launcher_foreground.xml"
ANDROID_COLORS="$ROOT_DIR/app/src/main/res/values/colors.xml"
IOS_PROJECT_FILE="$ROOT_DIR/ios/PakFitIOS/PakFitIOS.xcodeproj/project.pbxproj"
IOS_ICON_SET="$ROOT_DIR/ios/PakFitIOS/Assets.xcassets/AppIcon.appiconset"

for required_file in "$ANDROID_MANIFEST" "$ANDROID_ICON" "$ANDROID_ROUND_ICON" "$ANDROID_FOREGROUND" "$ANDROID_COLORS" "$IOS_PROJECT_FILE" "$IOS_ICON_SET/Contents.json"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing app icon input: $required_file" >&2
    exit 1
  fi
done

if ! grep -q 'android:icon="@mipmap/ic_launcher"' "$ANDROID_MANIFEST"; then
  echo "Android manifest must reference @mipmap/ic_launcher." >&2
  exit 1
fi
if ! grep -q 'android:roundIcon="@mipmap/ic_launcher_round"' "$ANDROID_MANIFEST"; then
  echo "Android manifest must reference @mipmap/ic_launcher_round." >&2
  exit 1
fi
if ! grep -q '@color/pakfit_icon_background' "$ANDROID_ICON" || ! grep -q '@drawable/ic_launcher_foreground' "$ANDROID_ICON"; then
  echo "Android adaptive launcher icon must use the PakFit background and foreground assets." >&2
  exit 1
fi
if ! grep -q '@color/pakfit_icon_background' "$ANDROID_ROUND_ICON" || ! grep -q '@drawable/ic_launcher_foreground' "$ANDROID_ROUND_ICON"; then
  echo "Android round adaptive launcher icon must use the PakFit background and foreground assets." >&2
  exit 1
fi
if ! grep -q 'pakfit_icon_background' "$ANDROID_COLORS"; then
  echo "Android icon background color must be defined." >&2
  exit 1
fi

APPICON_NAME_COUNT="$(grep -c 'ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;' "$IOS_PROJECT_FILE" | tr -d ' ')"
if [[ "$APPICON_NAME_COUNT" -lt 2 ]]; then
  echo "iOS Debug and Release build settings must use AppIcon." >&2
  exit 1
fi
if ! grep -q 'Assets.xcassets in Resources' "$IOS_PROJECT_FILE"; then
  echo "iOS Xcode project must include Assets.xcassets in Resources." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found; install Python 3 to validate iOS app icon dimensions." >&2
  exit 1
fi

python3 - "$IOS_ICON_SET" <<'PY'
import json
import struct
import sys
from pathlib import Path

icon_set = Path(sys.argv[1])
contents = json.loads((icon_set / "Contents.json").read_text())
images = contents.get("images", [])
if len(images) < 18:
    raise SystemExit("iOS AppIcon set must include iPhone, iPad, and marketing icon slots.")
if not any(image.get("idiom") == "ios-marketing" and image.get("size") == "1024x1024" for image in images):
    raise SystemExit("iOS AppIcon set must include a 1024x1024 ios-marketing icon.")

signature = b"\x89PNG\r\n\x1a\n"
for image in images:
    filename = image.get("filename")
    if not filename:
        raise SystemExit("Every iOS AppIcon image slot must reference a PNG filename.")
    path = icon_set / filename
    data = path.read_bytes()
    if not data.startswith(signature):
        raise SystemExit(f"AppIcon file is not a PNG: {filename}")
    width, height = struct.unpack(">II", data[16:24])
    point_size = float(image["size"].split("x")[0])
    scale = int(image["scale"].replace("x", ""))
    expected = round(point_size * scale)
    if width != expected or height != expected:
        raise SystemExit(f"Unexpected AppIcon dimensions for {filename}: {width}x{height}, expected {expected}x{expected}")
PY

echo "App icon asset gate passed."
