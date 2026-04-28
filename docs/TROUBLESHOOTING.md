# Troubleshooting

Codex Clipboard Control has one job: after you take a screenshot, `Cmd+V` in a supported terminal should paste a file path that your agent CLI can read.

## Quick Check

1. Open `~/Applications/Codex Clipboard Control.app`.
2. Confirm the status says the listener is running.
3. Take a new screenshot with your existing screenshot app.
4. Bring Terminal, iTerm2, Warp, Ghostty, Codex CLI, or another supported terminal to the front.
5. Press `Cmd+V`.

If it still fails, click `Restart` in the control panel and try one fresh screenshot.

## Run Diagnostics

```bash
zsh scripts/diagnose.sh
```

Send the diagnostic output with:

- macOS version
- terminal app name
- screenshot app name
- whether normal apps like Notes, WeChat, Feishu, or a browser can still paste the image

## Common Issues

### Nothing Happens In Terminal

Make sure the screenshot was taken after the listener started. Old clipboard items may not be converted.

### Terminal Pastes The Raw Image Or Nothing

The foreground app may not be recognized as a supported terminal. Run:

```bash
~/.local/bin/codex-frontmost-app
```

Then send the output so the app can be added to the terminal detection list.

### Normal Apps Paste A File Path Instead Of The Image

Switch away from the terminal and wait briefly. The background helper restores the clipboard back to the original image when a normal app is frontmost.

If it stays as text, click `Restart`.

### LaunchAgent Is Not Running

Run:

```bash
zsh scripts/install.sh
```

Or open the control panel and click `Enable`.

### Logs

Main log:

```text
/tmp/codex-auto-paste.log
```

Error log:

```text
/tmp/codex-auto-paste.stderr.log
```

Temporary images:

```text
/tmp/codex-clipboard-media
```
