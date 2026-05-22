#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="PowerModeStatusBar"

cleanup() {
  pkill -x "$APP_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

swift run --package-path "$ROOT_DIR" PowerModeCoreSmokeTests

"$ROOT_DIR/scripts/build_and_run.sh" --verify

pgrep -x "$APP_NAME" >/dev/null
pmset -g assertions | grep "$APP_NAME" >/dev/null

echo "PowerModeStatusBar app verification passed"
