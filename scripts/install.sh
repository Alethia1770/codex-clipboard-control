#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
INSTALL_ROOT="${CODEX_CLIPBOARD_INSTALL_ROOT:-$HOME/.local/share/codex-clipboard-control}"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$HOME/Applications"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_LABEL="com.codex.clipboard-auto-paste"
LAUNCH_AGENT_PATH="$LAUNCH_AGENTS_DIR/$LAUNCH_AGENT_LABEL.plist"
AUTO_PASTE_APP="$APPS_DIR/Codex Auto Paste Image.app"
PASTE_IMAGE_APP="$APPS_DIR/Codex Paste Image.app"
CONTROL_APP="$APPS_DIR/Codex Clipboard Control.app"
BUILD_DIR="$INSTALL_ROOT/build"
SRC_DIR="$INSTALL_ROOT/src"
BIN_INSTALL_DIR="$INSTALL_ROOT/bin"

mkdir -p "$INSTALL_ROOT" "$BIN_DIR" "$APPS_DIR" "$LAUNCH_AGENTS_DIR" "$BUILD_DIR" "$BIN_INSTALL_DIR"
rm -rf "$SRC_DIR"
mkdir -p "$SRC_DIR"
cp -R "$ROOT_DIR/src/." "$SRC_DIR"

echo "Compiling Swift helpers..."
swiftc -O "$SRC_DIR/swift/save_clipboard_image.swift" -o "$BIN_INSTALL_DIR/codex-clipboard-image-bin"
swiftc -O "$SRC_DIR/swift/clipboard_state.swift" -o "$BIN_INSTALL_DIR/codex-clipboard-state-bin"
swiftc -O "$SRC_DIR/swift/set_clipboard_image.swift" -o "$BIN_INSTALL_DIR/codex-clipboard-set-image-bin"
swiftc -O "$SRC_DIR/swift/frontmost_app.swift" -o "$BIN_INSTALL_DIR/codex-frontmost-app-bin"

cat > "$BIN_DIR/codex-clipboard-image" <<EOF
#!/bin/zsh
set -euo pipefail
compiled="$BIN_INSTALL_DIR/codex-clipboard-image-bin"
script="$SRC_DIR/swift/save_clipboard_image.swift"
output_dir="\${CODEX_CLIPBOARD_MEDIA_DIR:-/tmp/codex-clipboard-media}"
if [[ "\${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: codex-clipboard-image

Save the current macOS clipboard image to a PNG file and print the file path.
USAGE
  exit 0
fi
if [[ -x "\$compiled" ]]; then
  exec "\$compiled" "\$output_dir"
fi
exec /usr/bin/swift "\$script" "\$output_dir"
EOF

cat > "$BIN_DIR/codex-clipboard-state" <<EOF
#!/bin/zsh
set -euo pipefail
compiled="$BIN_INSTALL_DIR/codex-clipboard-state-bin"
script="$SRC_DIR/swift/clipboard_state.swift"
if [[ "\${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: codex-clipboard-state

Print the macOS pasteboard change count and whether the current clipboard item is an image.
USAGE
  exit 0
fi
if [[ -x "\$compiled" ]]; then
  exec "\$compiled"
fi
exec /usr/bin/swift "\$script"
EOF

cat > "$BIN_DIR/codex-clipboard-set-image" <<EOF
#!/bin/zsh
set -euo pipefail
compiled="$BIN_INSTALL_DIR/codex-clipboard-set-image-bin"
script="$SRC_DIR/swift/set_clipboard_image.swift"
if [[ "\${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: codex-clipboard-set-image <image-path>

Load an image file and put it onto the macOS clipboard as an image.
USAGE
  exit 0
fi
if (( \$# != 1 )); then
  print -u2 -- "Usage: codex-clipboard-set-image <image-path>"
  exit 1
fi
if [[ -x "\$compiled" ]]; then
  exec "\$compiled" "\$1"
fi
exec /usr/bin/swift "\$script" "\$1"
EOF

cat > "$BIN_DIR/codex-frontmost-app" <<EOF
#!/bin/zsh
set -euo pipefail
compiled="$BIN_INSTALL_DIR/codex-frontmost-app-bin"
script="$SRC_DIR/swift/frontmost_app.swift"
if [[ "\${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: codex-frontmost-app

Print the frontmost macOS app's localized name and bundle identifier.
USAGE
  exit 0
fi
if [[ -x "\$compiled" ]]; then
  exec "\$compiled"
fi
exec /usr/bin/swift "\$script"
EOF

echo "Building app bundles..."
osacompile -l JavaScript -o "$AUTO_PASTE_APP" "$SRC_DIR/jxa/Codex Auto Paste Image.js"
/usr/libexec/PlistBuddy -c 'Add :LSUIElement bool true' "$AUTO_PASTE_APP/Contents/Info.plist" >/dev/null 2>&1 || \
  /usr/libexec/PlistBuddy -c 'Set :LSUIElement true' "$AUTO_PASTE_APP/Contents/Info.plist" >/dev/null
/usr/bin/codesign --force --deep -s - "$AUTO_PASTE_APP" >/dev/null

osacompile -l JavaScript -o "$PASTE_IMAGE_APP" "$SRC_DIR/jxa/Codex Paste Image.js"
/usr/libexec/PlistBuddy -c 'Add :LSUIElement bool true' "$PASTE_IMAGE_APP/Contents/Info.plist" >/dev/null 2>&1 || \
  /usr/libexec/PlistBuddy -c 'Set :LSUIElement true' "$PASTE_IMAGE_APP/Contents/Info.plist" >/dev/null
/usr/bin/codesign --force --deep -s - "$PASTE_IMAGE_APP" >/dev/null

swiftc -parse-as-library -O -framework SwiftUI -framework AppKit \
  "$SRC_DIR/swift/CodexClipboardControl.swift" \
  -o "$BUILD_DIR/CodexClipboardControlUI"
osacompile -l JavaScript -o "$CONTROL_APP" "$SRC_DIR/jxa/CodexClipboardControlLauncher.js"
cp "$BUILD_DIR/CodexClipboardControlUI" "$CONTROL_APP/Contents/Resources/CodexClipboardControlUI"
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$CONTROL_APP/Contents/Info.plist" >/dev/null 2>&1 && \
  /usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier io.github.codexclipboardcontrol' "$CONTROL_APP/Contents/Info.plist" >/dev/null || \
  /usr/libexec/PlistBuddy -c 'Add :CFBundleIdentifier string io.github.codexclipboardcontrol' "$CONTROL_APP/Contents/Info.plist" >/dev/null
/usr/libexec/PlistBuddy -c 'Print :CFBundleName' "$CONTROL_APP/Contents/Info.plist" >/dev/null 2>&1 && \
  /usr/libexec/PlistBuddy -c 'Set :CFBundleName Codex Clipboard Control' "$CONTROL_APP/Contents/Info.plist" >/dev/null || \
  /usr/libexec/PlistBuddy -c 'Add :CFBundleName string Codex Clipboard Control' "$CONTROL_APP/Contents/Info.plist" >/dev/null
/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$CONTROL_APP/Contents/Info.plist" >/dev/null 2>&1 && \
  /usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName Codex Clipboard Control' "$CONTROL_APP/Contents/Info.plist" >/dev/null || \
  /usr/libexec/PlistBuddy -c 'Add :CFBundleDisplayName string Codex Clipboard Control' "$CONTROL_APP/Contents/Info.plist" >/dev/null
/usr/bin/codesign --force --deep -s - "$CONTROL_APP" >/dev/null

cat > "$BIN_DIR/codex-paste-image" <<EOF
#!/bin/zsh
set -euo pipefail
app="$PASTE_IMAGE_APP"
if [[ "\${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: codex-paste-image [image-path]

Without arguments, save the current clipboard image and paste the saved file path into the frontmost app.
With an image path argument, paste that file path into the frontmost app.
USAGE
  exit 0
fi
if (( \$# > 0 )); then
  exec open -g -a "\$app" -- "\$@"
fi
exec open -g -a "\$app"
EOF

cat > "$BIN_DIR/codex-clipboard-control-ui" <<EOF
#!/bin/zsh
set -euo pipefail
launcher="$CONTROL_APP/Contents/MacOS/applet"
if [[ "\${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: codex-clipboard-control-ui

Launch the Codex Clipboard Control graphical panel.
USAGE
  exit 0
fi
"\$launcher" >/tmp/codex-clipboard-control-launcher.stdout.log 2>/tmp/codex-clipboard-control-launcher.stderr.log </dev/null &!
EOF

chmod +x \
  "$BIN_DIR/codex-clipboard-image" \
  "$BIN_DIR/codex-clipboard-state" \
  "$BIN_DIR/codex-clipboard-set-image" \
  "$BIN_DIR/codex-frontmost-app" \
  "$BIN_DIR/codex-paste-image" \
  "$BIN_DIR/codex-clipboard-control-ui"

echo "Rendering LaunchAgent..."
sed \
  -e "s#__LABEL__#$LAUNCH_AGENT_LABEL#g" \
  -e "s#__AUTO_PASTE_APPLET__#$AUTO_PASTE_APP/Contents/MacOS/applet#g" \
  "$ROOT_DIR/templates/launchd/com.codex.clipboard-auto-paste.plist.template" > "$LAUNCH_AGENT_PATH"

uid="$(id -u)"
launchctl bootout "gui/$uid" "$LAUNCH_AGENT_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$uid" "$LAUNCH_AGENT_PATH"

cat <<EOF

Install complete.

Control panel:
  $BIN_DIR/codex-clipboard-control-ui

Manual paste helper:
  $BIN_DIR/codex-paste-image

LaunchAgent:
  $LAUNCH_AGENT_PATH
EOF
