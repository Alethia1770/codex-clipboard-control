#!/bin/zsh

set -euo pipefail

cd -- "$(dirname -- "$0")"
zsh scripts/install.sh

cat <<'EOF'

Install finished.

Open the control panel from:
  ~/Applications/Codex Clipboard Control.app

Daily workflow:
  1. Take a screenshot with your existing screenshot app.
  2. Return to Terminal, Codex, Claude Code, Warp, iTerm2, or Ghostty.
  3. Press Cmd+V.

If something does not work, run:
  zsh scripts/diagnose.sh

EOF

if [[ -t 0 ]]; then
  print -r -- "Press Return to close this window."
  read -r _
fi
