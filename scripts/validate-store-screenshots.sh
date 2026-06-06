#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

RENDERER="$ROOT_DIR/work/render_pakfit_screens.py"
SCREENSHOT_DIR="${PAKFIT_SCREENSHOT_DIR:-$ROOT_DIR/outputs/PakFit/screens}"
PYTHON_CMD="${PYTHON_CMD:-python3}"

if [[ ! -f "$RENDERER" ]]; then
  echo "Missing screenshot renderer: $RENDERER" >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep not found; install rg to run the screenshot language gate." >&2
  exit 1
fi
if rg -n "Urdu|اردو|[\u0600-\u06FF]" "$RENDERER"; then
  echo "Store screenshot renderer must stay English-only for the current release." >&2
  exit 1
fi

has_pillow() {
  "$1" - <<'PY' >/dev/null 2>&1
from PIL import Image
PY
}

if ! has_pillow "$PYTHON_CMD"; then
  BUNDLED_PYTHON="$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3"
  if [[ -x "$BUNDLED_PYTHON" ]] && has_pillow "$BUNDLED_PYTHON"; then
    PYTHON_CMD="$BUNDLED_PYTHON"
  else
    echo "Python Pillow is required to render and validate store screenshots. Set PYTHON_CMD to a Python with Pillow installed." >&2
    exit 1
  fi
fi

mkdir -p "$SCREENSHOT_DIR"
PAKFIT_SCREENSHOT_DIR="$SCREENSHOT_DIR" "$PYTHON_CMD" "$RENDERER" >/dev/null

"$PYTHON_CMD" - "$SCREENSHOT_DIR" <<'PY'
import sys
from pathlib import Path
from PIL import Image

screen_dir = Path(sys.argv[1])
expected = {
    "00-pakfit-screen-contact-sheet.png": (1120, 1450),
    "01-home-profile-plan.png": (1080, 1920),
    "02-health-markers-bmi-reports.png": (1080, 1920),
    "03-clinical-intelligence.png": (1080, 1920),
    "04-mental-wellness-crisis.png": (1080, 1920),
    "05-analysis-dashboard.png": (1080, 1920),
    "06-food-logging-records.png": (1080, 1920),
}

missing = [name for name in expected if not (screen_dir / name).is_file()]
if missing:
    raise SystemExit(f"Missing generated screenshot files: {', '.join(missing)}")

for name, size in expected.items():
    path = screen_dir / name
    with Image.open(path) as image:
        if image.format != "PNG":
            raise SystemExit(f"Screenshot is not a PNG: {name}")
        if image.size != size:
            raise SystemExit(f"Unexpected dimensions for {name}: {image.size}, expected {size}")
        thumb = image.convert("RGB").resize((64, 64))
        unique_colors = len(thumb.getcolors(maxcolors=4096) or [])
        if unique_colors < 24:
            raise SystemExit(f"Screenshot appears blank or too low-detail: {name}")
        if path.stat().st_size < 20_000:
            raise SystemExit(f"Screenshot file is unexpectedly small: {name}")

print(f"Store screenshot gate passed: {len(expected)} PNGs in {screen_dir}.")
PY
