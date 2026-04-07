ObjC.import("Foundation");

function run() {
  pastePath("");
}

function openDocuments(droppedItems) {
  if (droppedItems.length === 0) {
    pastePath("");
    return;
  }

  pastePath(String(droppedItems[0]));
}

function pastePath(imagePath) {
  const app = Application.currentApplication();
  app.includeStandardAdditions = true;
  const homeDirectory = ObjC.unwrap($.NSHomeDirectory());

  let resolvedPath = imagePath || "";

  if (!resolvedPath) {
    try {
      resolvedPath = app.doShellScript(shellQuote(homeDirectory + "/.local/bin/codex-clipboard-image"));
    } catch (error) {
      app.displayNotification(String(error), { withTitle: "Codex Paste Image" });
      return;
    }
  }

  app.setTheClipboardTo(resolvedPath + " ");
  delay(0.1);

  const systemEvents = Application("System Events");
  systemEvents.keystroke("v", { using: ["command down"] });
}

function shellQuote(text) {
  return "'" + String(text).replace(/'/g, "'\\''") + "'";
}
