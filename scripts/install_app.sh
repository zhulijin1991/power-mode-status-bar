#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PowerModeStatusBar"
DISPLAY_APP_NAME="电源模式.app"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_APP="$ROOT_DIR/dist/$APP_NAME.app"
INSTALL_DIR="$HOME/Applications"
TARGET_APP="$INSTALL_DIR/$DISPLAY_APP_NAME"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

"$ROOT_DIR/scripts/build_and_run.sh" --build-only

pkill -x "$APP_NAME" >/dev/null 2>&1 || true
mkdir -p "$INSTALL_DIR"
rm -rf "$TARGET_APP"
/usr/bin/ditto "$SOURCE_APP" "$TARGET_APP"

if [[ -x "$LSREGISTER" ]]; then
  "$LSREGISTER" -f "$TARGET_APP" >/dev/null 2>&1 || true
fi

/usr/bin/open -n "$TARGET_APP"
echo "$TARGET_APP"
