#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
NAME="codex-clipboard-control"
STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="$DIST_DIR/$NAME-$STAMP.zip"

mkdir -p "$DIST_DIR"
rm -f "$ARCHIVE"

cd "$ROOT_DIR/.."
/usr/bin/zip -r "$ARCHIVE" "$NAME" \
  -x "$NAME/.git/*" \
  -x "$NAME/dist/*" \
  -x "$NAME/.DS_Store"

echo "$ARCHIVE"
