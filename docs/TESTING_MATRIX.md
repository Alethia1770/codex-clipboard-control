# Stage 1 Testing Matrix

Use this matrix before sharing a build with early users.

## Core Workflow

| Case | Expected Result | Status |
| --- | --- | --- |
| Install from `install.command` | Apps, helpers, and LaunchAgent are installed | Untested |
| Install from `zsh scripts/install.sh` | Same result as `install.command` | Untested |
| Open control panel | Listener status is visible | Untested |
| Click Restart | LaunchAgent restarts without error | Untested |
| Take screenshot, paste into Terminal.app | Pastes image file path | Untested |
| Take screenshot, paste into iTerm2 | Pastes image file path | Untested |
| Take screenshot, paste into Warp | Pastes image file path | Untested |
| Take screenshot, paste into Ghostty | Pastes image file path | Untested |
| Paste into Notes, browser, WeChat, or Feishu | Pastes the original image, not a path | Untested |
| Uninstall with `zsh scripts/uninstall.sh` | Apps, helpers, LaunchAgent are removed | Untested |

## Screenshot Apps

| Screenshot Tool | Expected Result | Status |
| --- | --- | --- |
| macOS system screenshot | Clipboard image converts in terminal | Untested |
| iShot | Clipboard image converts in terminal | Untested |
| CleanShot X | Clipboard image converts in terminal | Untested |
| Shottr | Clipboard image converts in terminal | Untested |

## Agent CLIs

| Agent CLI | Expected Result | Status |
| --- | --- | --- |
| Codex CLI | Image path is accepted | Untested |
| Claude Code | Image path is accepted if the CLI supports image paths | Untested |
| Gemini CLI | Image path is accepted if the CLI supports image paths | Untested |

## Regression Checks

| Case | Expected Result | Status |
| --- | --- | --- |
| Listener is stopped | Clipboard behaves like normal macOS clipboard | Untested |
| Cache clear button | Temporary screenshot files are removed | Untested |
| Log clear button | Log files reset | Untested |
| App icon in Dock | Uses red screenshot-terminal icon | Untested |
| Header icon in control panel | Matches Dock icon | Untested |

## Early User Feedback Questions

Ask each tester:

1. Did you understand the product from the first screen?
2. Did install feel safe enough?
3. Did it work with your screenshot app and terminal?
4. Did you keep it running after the first day?
5. Would you pay a small one-time price for this exact workflow?
