#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESOURCES_DIR="$ROOT_DIR/Resources"
SVG_FILE="$RESOURCES_DIR/AppIcon.svg"
ICONSET_DIR="$RESOURCES_DIR/AppIcon.iconset"
PREVIEW_FILE="$RESOURCES_DIR/AppIcon-1024.png"
ICNS_FILE="$RESOURCES_DIR/AppIcon.icns"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

SOURCE_PNG="$TMP_DIR/AppIcon-1024.png"
/usr/bin/sips -s format png "$SVG_FILE" --out "$SOURCE_PNG" >/dev/null
/usr/bin/sips -s format png "$SOURCE_PNG" --out "$PREVIEW_FILE" >/dev/null

make_icon() {
  local output="$1"
  local pixels="$2"
  /usr/bin/sips -z "$pixels" "$pixels" "$SOURCE_PNG" --out "$ICONSET_DIR/$output" >/dev/null
}

make_icon icon_16x16.png 16
make_icon icon_16x16@2x.png 32
make_icon icon_32x32.png 32
make_icon icon_32x32@2x.png 64
make_icon icon_128x128.png 128
make_icon icon_128x128@2x.png 256
make_icon icon_256x256.png 256
make_icon icon_256x256@2x.png 512
make_icon icon_512x512.png 512
make_icon icon_512x512@2x.png 1024

/usr/bin/iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE"
echo "$ICNS_FILE"
