#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

CLIP_DIR="$ROOT_DIR/docs/video-clips"
OUTPUT_FILE="$ROOT_DIR/docs/PRODUCT_DEMO.mp4"
FILELIST="$CLIP_DIR/filelist.txt"
mkdir -p "$CLIP_DIR"

if ! command -v ffmpeg >/dev/null 2>&1; then
  cat > "$FILELIST" <<'EOF'
# ffmpeg is not installed.
# Add one line per clip after recording native Android/iOS demo video:
# file 'office-worker-demo.webm'
# file 'health-reviewer-demo.webm'
# file 'mental-wellness-demo.webm'
EOF
  echo "ffmpeg not found. Wrote manual assembly template: $FILELIST"
  exit 0
fi

if [[ ! -f "$CLIP_DIR/office-worker-demo.webm" || ! -f "$CLIP_DIR/health-reviewer-demo.webm" || ! -f "$CLIP_DIR/mental-wellness-demo.webm" ]]; then
  node scripts/record-demo.js
fi

cat > "$FILELIST" <<EOF
file '$CLIP_DIR/office-worker-demo.webm'
file '$CLIP_DIR/health-reviewer-demo.webm'
file '$CLIP_DIR/mental-wellness-demo.webm'
EOF

ffmpeg -y -f concat -safe 0 -i "$FILELIST" -c copy "$OUTPUT_FILE"
echo "$OUTPUT_FILE"
