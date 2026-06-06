#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep not found; install rg to run the photo privacy gate." >&2
  exit 1
fi

ANDROID_SOURCE_DIR="$ROOT_DIR/app/src/main/java"
IOS_APP_SOURCE_DIR="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp"
IOS_CORE_SOURCE_DIR="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore"
ANDROID_UI_FILE="$ROOT_DIR/app/src/main/java/com/pakfit/app/ui/PakFitApp.kt"
IOS_UI_FILE="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PakFitScreens.swift"

if [[ ! -f "$ANDROID_UI_FILE" ]]; then
  echo "Missing Android UI file for photo privacy validation: $ANDROID_UI_FILE" >&2
  exit 1
fi
if [[ ! -f "$IOS_UI_FILE" ]]; then
  echo "Missing iOS UI file for photo privacy validation: $IOS_UI_FILE" >&2
  exit 1
fi

if ! rg -q "ActivityResultContracts\\.TakePicturePreview" "$ANDROID_UI_FILE"; then
  echo "Android photo workflow must use preview-only capture instead of writing a camera file." >&2
  exit 1
fi
if ! rg -q "PhotosPicker|UIImagePickerController" "$IOS_UI_FILE"; then
  echo "iOS photo workflow must keep explicit photo picker/camera controls visible in source." >&2
  exit 1
fi

ANDROID_FORBIDDEN_PATTERN="Bitmap\\.compress|MediaStore|FileOutputStream|openFileOutput|openOutputStream|contentResolver\\.openOutputStream|imageBytes|photoBytes|multipart|Multipart|OkHttpClient|Retrofit|HttpURLConnection"
IOS_FORBIDDEN_PATTERN="\\.jpegData|\\.pngData|UIImageWriteToSavedPhotosAlbum|URLSession|multipart|Multipart|imageBytes|photoBytes"

if rg -n "$ANDROID_FORBIDDEN_PATTERN" "$ANDROID_SOURCE_DIR"; then
  echo "Android photo privacy gate failed: food photo bytes must not be persisted or uploaded in this build." >&2
  exit 1
fi
if rg -n "$IOS_FORBIDDEN_PATTERN" "$IOS_APP_SOURCE_DIR" "$IOS_CORE_SOURCE_DIR"; then
  echo "iOS photo privacy gate failed: food photo bytes must not be persisted or uploaded in this build." >&2
  exit 1
fi

echo "Photo privacy gate passed."
