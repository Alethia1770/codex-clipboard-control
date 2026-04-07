ObjC.import("Foundation");

var app = Application.currentApplication();
app.includeStandardAdditions = true;

var homeDirectory = ObjC.unwrap($.NSHomeDirectory());
var logPath = "/tmp/codex-auto-paste.log";
var isTransforming = false;
var lastDeferredImageChangeCount = null;
var managedImagePath = null;

function run() {
  logLine("agent started");
}

function idle() {
  try {
    if (isTransforming) {
      return 0.5;
    }

    var state = readClipboardState();
    if (!state) {
      return 0.5;
    }

    var frontmost = getFrontmostAppInfo();

    if (state.kind !== "image") {
      maybeRestoreManagedImage(frontmost);
      return 0.1;
    }

    if (!isSupportedFrontmostApp(frontmost)) {
      if (lastDeferredImageChangeCount !== state.changeCount) {
        logLine(
          "deferred image clipboard because frontmost app is unsupported: " +
            frontmost.name +
            " [" +
            frontmost.bundleId +
            "]"
        );
        lastDeferredImageChangeCount = state.changeCount;
      }
      return 0.1;
    }

    isTransforming = true;
    delay(0.05);

    var imagePath = app.doShellScript(helperBinary("codex-clipboard-image"));
    app.setTheClipboardTo(imagePath + " ");
    managedImagePath = imagePath;
    delay(0.02);

    var postState = readClipboardState();
    if (postState && postState.kind === "image") {
      logLine("replacement attempted but clipboard still looks like image: " + imagePath);
    } else {
      logLine("replaced image clipboard with path: " + imagePath);
      lastDeferredImageChangeCount = null;
    }
  } catch (error) {
    logLine("error: " + String(error));
  } finally {
    isTransforming = false;
  }

  return 0.1;
}

function maybeRestoreManagedImage(frontmost) {
  if (!managedImagePath) {
    lastDeferredImageChangeCount = null;
    return;
  }

  if (isSupportedFrontmostApp(frontmost)) {
    return;
  }

  var clipboardText = readClipboardText().trim();
  if (!clipboardText) {
    return;
  }

  if (clipboardText !== managedImagePath) {
    managedImagePath = null;
    lastDeferredImageChangeCount = null;
    return;
  }

  isTransforming = true;

  try {
    app.doShellScript(
      helperBinary("codex-clipboard-set-image") + " " + shellQuote(managedImagePath)
    );
    lastDeferredImageChangeCount = null;
    logLine(
      "restored managed image clipboard for non-terminal app: " +
        frontmost.name +
        " [" +
        frontmost.bundleId +
        "]"
    );
  } catch (error) {
    logLine("restore failed: " + String(error));
  } finally {
    isTransforming = false;
  }
}

function readClipboardState() {
  try {
    var raw = app.doShellScript(helperBinary("codex-clipboard-state"));
    var parts = raw.split("\t");
    if (parts.length < 2) {
      logLine("unexpected clipboard-state output: " + raw);
      return null;
    }

    return {
      changeCount: String(parts[0]).trim(),
      kind: String(parts[1]).trim(),
    };
  } catch (error) {
    logLine("clipboard-state failed: " + String(error));
    return null;
  }
}

function readClipboardText() {
  try {
    return app.doShellScript("/usr/bin/pbpaste");
  } catch (error) {
    logLine("clipboard-text read failed: " + String(error));
    return "";
  }
}

function getFrontmostAppInfo() {
  try {
    var raw = app.doShellScript(helperBinary("codex-frontmost-app"));
    var parts = raw.split("\t");
    var name = parts.length > 0 ? String(parts[0]).trim() : "";
    var bundleId = parts.length > 1 ? String(parts[1]).trim() : "";

    return { name: name, bundleId: bundleId };
  } catch (error) {
    logLine("frontmost-app lookup failed: " + String(error));
    return { name: "", bundleId: "" };
  }
}

function isSupportedFrontmostApp(frontmost) {
  var name = frontmost.name || "";
  var bundleId = frontmost.bundleId || "";

  if (bundleId === "com.apple.Terminal") {
    return true;
  }

  if (bundleId === "com.googlecode.iterm2") {
    return true;
  }

  if (bundleId === "dev.warp.Warp-Stable" || bundleId === "dev.warp.Warp") {
    return true;
  }

  if (bundleId === "com.mitchellh.ghostty") {
    return true;
  }

  return (
    name.indexOf("Terminal") !== -1 ||
    name.indexOf("iTerm") !== -1 ||
    name.indexOf("Warp") !== -1 ||
    name.indexOf("Ghostty") !== -1
  );
}

function logLine(message) {
  try {
    app.doShellScript(
      "/bin/echo " + shellQuote(timestamp() + " " + message) + " >> " + shellQuote(logPath)
    );
  } catch (error) {}
}

function helperBinary(name) {
  return shellQuote(homeDirectory + "/.local/bin/" + name);
}

function shellQuote(text) {
  return "'" + String(text).replace(/'/g, "'\\''") + "'";
}

function timestamp() {
  return app.doShellScript("/bin/date '+%Y-%m-%d %H:%M:%S'");
}
