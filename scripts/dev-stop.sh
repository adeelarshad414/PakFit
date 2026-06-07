#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LOG_DIR="$ROOT_DIR/logs"
PID_FILE="$LOG_DIR/dev-pids.txt"
PORTS=(${PAKFIT_DEV_PORTS:-})

mkdir -p "$LOG_DIR"

if [[ -f "$PID_FILE" ]]; then
  while IFS= read -r pid; do
    if [[ -n "$pid" ]] && kill -0 "$pid" >/dev/null 2>&1; then
      kill "$pid" >/dev/null 2>&1 || true
    fi
  done < "$PID_FILE"
  : > "$PID_FILE"
fi

for port in "${PORTS[@]}"; do
  if command -v lsof >/dev/null 2>&1; then
    while IFS= read -r pid; do
      [[ -n "$pid" ]] && kill -9 "$pid" >/dev/null 2>&1 || true
    done < <(lsof -ti :"$port" 2>/dev/null || true)
  fi
done

if [[ "${PAKFIT_DEV_STOP_GRADLE_DAEMON:-0}" == "1" && -x "$ROOT_DIR/gradlew" ]]; then
  "$ROOT_DIR/gradlew" --stop >/dev/null 2>&1 || true
fi

echo "PakFit dev cleanup complete."
if [[ "${#PORTS[@]}" -eq 0 ]]; then
  echo "No fixed app ports are used by PakFit's native local workflow."
else
  for port in "${PORTS[@]}"; do
    if command -v lsof >/dev/null 2>&1 && lsof -ti :"$port" >/dev/null 2>&1; then
      echo "Port $port still in use"
    else
      echo "Port $port is free"
    fi
  done
fi
