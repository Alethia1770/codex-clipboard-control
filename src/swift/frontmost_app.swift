import AppKit

if let app = NSWorkspace.shared.frontmostApplication {
    let name = app.localizedName ?? ""
    let bundleIdentifier = app.bundleIdentifier ?? ""
    print("\(name)\t\(bundleIdentifier)")
} else {
    print("\t")
}
