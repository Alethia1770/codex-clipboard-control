#!/bin/zsh

set -euo pipefail

INSTALL_ROOT="${CODEX_CLIPBOARD_INSTALL_ROOT:-$HOME/.local/share/codex-clipboard-control}"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$HOME/Applications"
LAUNCH_AGENT_LABEL="com.codex.clipboard-auto-paste"
LAUNCH_AGENT_PATH="$HOME/Library/LaunchAgents/$LAUNCH_AGENT_LABEL.plist"
uid="$(id -u)"

launchctl bootout "gui/$uid" "$LAUNCH_AGENT_PATH" >/dev/null 2>&1 || true

rm -f \
  "$BIN_DIR/codex-clipboard-image" \
  "$BIN_DIR/codex-clipboard-state" \
  "$BIN_DIR/codex-clipboard-set-image" \
  "$BIN_DIR/codex-frontmost-app" \
  "$BIN_DIR/codex-paste-image" \
  "$BIN_DIR/codex-clipboard-control-ui"

rm -rf \
  "$INSTALL_ROOT" \
  "$APPS_DIR/Codex Auto Paste Image.app" \
  "$APPS_DIR/Codex Paste Image.app" \
  "$APPS_DIR/Codex Clipboard Control.app"

rm -f "$LAUNCH_AGENT_PATH"

echo "Uninstalled codex-clipboard-control."
