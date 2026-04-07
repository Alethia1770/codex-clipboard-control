import AppKit

let pb = NSPasteboard.general
let hasImage = NSImage(pasteboard: pb) != nil
print("\(pb.changeCount)\t\(hasImage ? "image" : "other")")
