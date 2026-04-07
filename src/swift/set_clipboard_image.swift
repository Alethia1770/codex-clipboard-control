import AppKit
import Foundation

func fail(_ message: String, code: Int32 = 1) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(code)
}

guard CommandLine.arguments.count > 1 else {
    fail("Usage: set_clipboard_image.swift <image-path>")
}

let path = CommandLine.arguments[1]
let url = URL(fileURLWithPath: path)

guard FileManager.default.fileExists(atPath: path) else {
    fail("Image file does not exist: \(path)")
}

guard let image = NSImage(contentsOf: url) else {
    fail("Failed to load image from: \(path)")
}

let pasteboard = NSPasteboard.general
pasteboard.clearContents()

guard pasteboard.writeObjects([image]) else {
    fail("Failed to write image to clipboard.")
}
