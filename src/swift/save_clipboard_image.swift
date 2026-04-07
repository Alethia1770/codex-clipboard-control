import AppKit
import Foundation

func fail(_ message: String, code: Int32 = 1) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(code)
}

let outputDirectory: URL = {
    if CommandLine.arguments.count > 1 {
        return URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    }

    return URL(fileURLWithPath: "/tmp/codex-clipboard-media", isDirectory: true)
}()

do {
    try FileManager.default.createDirectory(
        at: outputDirectory,
        withIntermediateDirectories: true
    )
} catch {
    fail("Failed to create output directory: \(error.localizedDescription)")
}

guard let image = NSImage(pasteboard: NSPasteboard.general) else {
    fail("Clipboard does not contain an image.")
}

guard
    let tiffData = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiffData),
    let pngData = bitmap.representation(using: .png, properties: [:])
else {
    fail("Failed to convert the clipboard image to PNG.")
}

let formatter = DateFormatter()
formatter.calendar = Calendar(identifier: .gregorian)
formatter.locale = Locale(identifier: "en_US_POSIX")
formatter.timeZone = TimeZone.current
formatter.dateFormat = "yyyyMMdd-HHmmss"

let filename = "clip-\(formatter.string(from: Date()))-\(UUID().uuidString.prefix(8)).png"
let outputFile = outputDirectory.appendingPathComponent(filename, isDirectory: false)

do {
    try pngData.write(to: outputFile, options: .atomic)
    print(outputFile.path)
} catch {
    fail("Failed to write image: \(error.localizedDescription)")
}
