#!/bin/zsh

set -u

LABEL="com.codex.clipboard-auto-paste"
UID_VALUE="$(id -u)"
LAUNCH_AGENT_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
CONTROL_APP="$HOME/Applications/Codex Clipboard Control.app"
AUTO_PASTE_APP="$HOME/Applications/Codex Auto Paste Image.app"
HELPER_DIR="$HOME/.local/bin"
CACHE_DIR="${CODEX_CLIPBOARD_MEDIA_DIR:-/tmp/codex-clipboard-media}"
MAIN_LOG="/tmp/codex-auto-paste.log"
STDERR_LOG="/tmp/codex-auto-paste.stderr.log"

section() {
  print -r -- ""
  print -r -- "== $1 =="
}

exists() {
  if [[ -e "$1" ]]; then
    print -r -- "OK  $1"
  else
    print -r -- "MISS $1"
  fi
}

section "System"
sw_vers 2>/dev/null || true
print -r -- "Shell: $SHELL"
print -r -- "User: $(whoami)"

section "Installed Files"
exists "$CONTROL_APP"
exists "$AUTO_PASTE_APP"
exists "$LAUNCH_AGENT_PATH"
exists "$HELPER_DIR/codex-clipboard-image"
exists "$HELPER_DIR/codex-clipboard-state"
exists "$HELPER_DIR/codex-clipboard-set-image"
exists "$HELPER_DIR/codex-frontmost-app"

section "LaunchAgent"
launchctl print "gui/$UID_VALUE/$LABEL" 2>&1 | sed -n '1,80p'

section "Frontmost App"
"$HELPER_DIR/codex-frontmost-app" 2>&1 || true

section "Clipboard State"
"$HELPER_DIR/codex-clipboard-state" 2>&1 || true

section "Cache"
if [[ -d "$CACHE_DIR" ]]; then
  find "$CACHE_DIR" -maxdepth 1 -type f -print 2>/dev/null | tail -n 20
else
  print -r -- "Cache directory does not exist yet: $CACHE_DIR"
fi

section "Recent Log"
if [[ -f "$MAIN_LOG" ]]; then
  tail -n 40 "$MAIN_LOG"
else
  print -r -- "No main log yet: $MAIN_LOG"
fi

section "Recent Error Log"
if [[ -f "$STDERR_LOG" ]]; then
  tail -n 40 "$STDERR_LOG"
else
  print -r -- "No stderr log yet: $STDERR_LOG"
fi

section "Next Steps"
cat <<'EOF'
If paste fails:
1. Open Codex Clipboard Control and click Restart.
2. Take a fresh screenshot while the listener is running.
3. Bring a supported terminal to the front.
4. Press Cmd+V.
5. Send this diagnostic output with the terminal app name and screenshot app name.
EOF
