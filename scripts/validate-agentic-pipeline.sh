#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REQUIRED_FILES=(
  ".vscode/tasks.json"
  "docs/agentic-pipeline.md"
  "docs/SPEC_MAP.json"
  "docs/SPEC_MAP.md"
  "docs/TEST_CREDENTIALS.csv"
  "docs/COMMANDS_QUICKREF.md"
  "docs/LOCAL_SETUP_GUIDE.md"
  "docs/LOCAL_SETUP_GUIDE.docx"
  "docs/VIDEO_SCRIPT.md"
  "docs/VOICEOVER_RECORDING_GUIDE.md"
  "docs/screenshots/INDEX.md"
  "docs/video-clips/DEMO_RECORDING_PLAN.md"
  "docs/video-clips/filelist.txt"
  "scripts/dev-start.sh"
  "scripts/dev-stop.sh"
  "scripts/dev-restart.sh"
  "scripts/dev-start.ps1"
  "scripts/dev-stop.ps1"
  "scripts/capture-screenshots.js"
  "scripts/record-demo.js"
  "scripts/assemble-video.sh"
  "scripts/validate-agentic-pipeline.sh"
  "specs/067-agentic-development-pipeline-gate.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing agentic pipeline file: $file" >&2
    exit 1
  fi
done

require_text() {
  local file="$1"
  local text="$2"
  local description="$3"
  if ! grep -Fq "$text" "$file"; then
    echo "$description is missing from $file: $text" >&2
    exit 1
  fi
}

require_text docs/SPEC_MAP.json '"backend": "none"' "SPEC_MAP native backend boundary"
require_text docs/SPEC_MAP.json '"database": "none"' "SPEC_MAP native database boundary"
require_text docs/SPEC_MAP.json '"route": "native://dashboard"' "SPEC_MAP native dashboard route"
require_text docs/SPEC_MAP.json '"ramadan_diabetes_medication_user"' "SPEC_MAP Ramadan diabetes persona"
require_text docs/TEST_CREDENTIALS.csv "N/A-local-only" "Test credentials local-only login boundary"
require_text docs/COMMANDS_QUICKREF.md "PakFit is a native Android/iOS application" "Quickref native stack statement"
require_text docs/COMMANDS_QUICKREF.md "bash scripts/dev-start.sh" "Quickref start command"
require_text docs/COMMANDS_QUICKREF.md "bash scripts/dev-stop.sh" "Quickref stop command"
require_text docs/COMMANDS_QUICKREF.md "node scripts/capture-screenshots.js" "Quickref screenshot command"
require_text docs/LOCAL_SETUP_GUIDE.md "Backend: none in this build." "Setup guide backend boundary"
require_text docs/VIDEO_SCRIPT.md "PakFit is a Pakistani health, fitness, workout, and nutrition coach" "Video script intro"
require_text docs/VOICEOVER_RECORDING_GUIDE.md "No promise of cure, diagnosis, prescribed treatment, or guaranteed weight loss." "Voiceover safety review"
require_text docs/screenshots/INDEX.md "PakFit Screenshot Gallery" "Screenshot gallery title"
require_text docs/video-clips/DEMO_RECORDING_PLAN.md "PakFit Demo Recording Plan" "Demo recording plan title"
require_text docs/video-clips/filelist.txt "ffmpeg is not installed" "Demo assembly fallback filelist"
require_text scripts/dev-start.sh "No persistent services were started" "Dev start native no-service summary"
require_text scripts/dev-stop.sh "No fixed app ports are used" "Dev stop native port boundary"
require_text scripts/capture-screenshots.js "validate-store-screenshots.sh" "Screenshot script store renderer reuse"
require_text scripts/record-demo.js "PakFit is a native Android/iOS app" "Demo script native boundary"
require_text .vscode/tasks.json "Start PakFit Native Validation" "VS Code start task"
require_text README.md "Agentic developer pipeline" "README agentic pipeline feature"
require_text scripts/validate-release.sh "agentic pipeline gate" "Release validation agentic pipeline gate"
require_text scripts/generate-release-report.sh "AGENTIC_PIPELINE_DOC_FILE" "Release report agentic pipeline doc variable"
require_text scripts/generate-release-report.sh "## Agentic Development Pipeline" "Release report agentic pipeline section"
require_text .github/workflows/pakfit-ci.yml "Validate agentic development pipeline" "CI agentic pipeline validation"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to validate docs/SPEC_MAP.json." >&2
  exit 1
fi
python3 -m json.tool docs/SPEC_MAP.json >/dev/null

for executable in scripts/dev-start.sh scripts/dev-stop.sh scripts/dev-restart.sh scripts/capture-screenshots.js scripts/record-demo.js scripts/assemble-video.sh scripts/validate-agentic-pipeline.sh; do
  if [[ ! -x "$executable" ]]; then
    echo "Script must be executable: $executable" >&2
    exit 1
  fi
done

echo "Agentic development pipeline gate passed."
