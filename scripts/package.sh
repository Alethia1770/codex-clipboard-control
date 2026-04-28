#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
NAME="codex-clipboard-control"
STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="$DIST_DIR/$NAME-$STAMP.zip"

mkdir -p "$DIST_DIR"
rm -f "$ARCHIVE"

chmod +x \
  "$ROOT_DIR/install.command" \
  "$ROOT_DIR/scripts/install.sh" \
  "$ROOT_DIR/scripts/uninstall.sh" \
  "$ROOT_DIR/scripts/diagnose.sh" \
  "$ROOT_DIR/scripts/package.sh"

cd "$ROOT_DIR/.."
/usr/bin/zip -r "$ARCHIVE" "$NAME" \
  -x "$NAME/.git/*" \
  -x "$NAME/dist/*" \
  -x "$NAME/.DS_Store"

cat <<EOF
$ARCHIVE

Release zip created.

Early user install path:
  1. Unzip the archive.
  2. Open the codex-clipboard-control folder.
  3. Double-click install.command.

CLI install path:
  zsh scripts/install.sh
EOF
