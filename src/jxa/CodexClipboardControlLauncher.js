ObjC.import("AppKit");
ObjC.import("Foundation");

function run() {
  const app = Application.currentApplication();
  app.includeStandardAdditions = true;

  const bundlePath = ObjC.unwrap($.NSBundle.mainBundle.bundlePath);
  const executablePath = bundlePath + "/Contents/Resources/CodexClipboardControlUI";
  const stdoutLog = "/tmp/codex-clipboard-control-ui.stdout.log";
  const stderrLog = "/tmp/codex-clipboard-control-ui.stderr.log";

  try {
    const command =
      "/bin/sh -c " +
      shellQuote(shellQuote(executablePath) + " >" + shellQuote(stdoutLog) + " 2>" + shellQuote(stderrLog) + " &");
    app.doShellScript(command);
  } catch (error) {
    app.displayAlert("Codex Clipboard Control 启动失败", {
      message: String(error),
      as: "critical",
    });
  }
}

function shellQuote(text) {
  return "'" + String(text).replace(/'/g, "'\\''") + "'";
}
