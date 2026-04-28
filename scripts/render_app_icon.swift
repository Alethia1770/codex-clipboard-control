import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resources = root.appendingPathComponent("resources", isDirectory: true)
let iconset = resources.appendingPathComponent("AppIcon.iconset", isDirectory: true)

try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

func color(_ hex: UInt32) -> CGColor {
    let red = CGFloat((hex >> 16) & 0xff) / 255
    let green = CGFloat((hex >> 8) & 0xff) / 255
    let blue = CGFloat(hex & 0xff) / 255
    return CGColor(red: red, green: green, blue: blue, alpha: 1)
}

func stroke(_ context: CGContext, width: CGFloat, alpha: CGFloat = 1) {
    context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: alpha))
    context.setLineWidth(width)
    context.setLineCap(.round)
    context.setLineJoin(.round)
}

func drawIcon(into context: CGContext, size: Int) {
    let scale = CGFloat(size) / 1024

    context.saveGState()
    context.translateBy(x: 0, y: CGFloat(size))
    context.scaleBy(x: scale, y: -scale)
    context.setShouldAntialias(true)
    context.setAllowsAntialiasing(true)

    context.setFillColor(color(0xFF1818))
    context.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: 1024, height: 1024), cornerWidth: 224, cornerHeight: 224, transform: nil))
    context.fillPath()

    stroke(context, width: 48)
    let topLeft = CGMutablePath()
    topLeft.move(to: CGPoint(x: 172, y: 307))
    topLeft.addLine(to: CGPoint(x: 172, y: 223))
    topLeft.addCurve(to: CGPoint(x: 248, y: 147), control1: CGPoint(x: 172, y: 181), control2: CGPoint(x: 206, y: 147))
    topLeft.addLine(to: CGPoint(x: 332, y: 147))
    context.addPath(topLeft)
    context.strokePath()

    let topRight = CGMutablePath()
    topRight.move(to: CGPoint(x: 692, y: 147))
    topRight.addLine(to: CGPoint(x: 776, y: 147))
    topRight.addCurve(to: CGPoint(x: 852, y: 223), control1: CGPoint(x: 818, y: 147), control2: CGPoint(x: 852, y: 181))
    topRight.addLine(to: CGPoint(x: 852, y: 307))
    context.addPath(topRight)
    context.strokePath()

    let bottomRight = CGMutablePath()
    bottomRight.move(to: CGPoint(x: 852, y: 717))
    bottomRight.addLine(to: CGPoint(x: 852, y: 801))
    bottomRight.addCurve(to: CGPoint(x: 776, y: 877), control1: CGPoint(x: 852, y: 843), control2: CGPoint(x: 818, y: 877))
    bottomRight.addLine(to: CGPoint(x: 692, y: 877))
    context.addPath(bottomRight)
    context.strokePath()

    let bottomLeft = CGMutablePath()
    bottomLeft.move(to: CGPoint(x: 332, y: 877))
    bottomLeft.addLine(to: CGPoint(x: 248, y: 877))
    bottomLeft.addCurve(to: CGPoint(x: 172, y: 801), control1: CGPoint(x: 206, y: 877), control2: CGPoint(x: 172, y: 843))
    bottomLeft.addLine(to: CGPoint(x: 172, y: 717))
    context.addPath(bottomLeft)
    context.strokePath()

    stroke(context, width: 56)
    let chevron = CGMutablePath()
    chevron.move(to: CGPoint(x: 365, y: 365))
    chevron.addLine(to: CGPoint(x: 512, y: 512))
    chevron.addLine(to: CGPoint(x: 365, y: 659))
    context.addPath(chevron)
    context.strokePath()

    let cursor = CGMutablePath()
    cursor.move(to: CGPoint(x: 642, y: 365))
    cursor.addLine(to: CGPoint(x: 642, y: 659))
    context.addPath(cursor)
    context.strokePath()

    context.restoreGState()
}

func writePNG(size: Int, to url: URL) throws {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 32
    ) else {
        throw NSError(domain: "IconRenderer", code: 1)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    drawIcon(into: NSGraphicsContext.current!.cgContext, size: size)
    NSGraphicsContext.restoreGraphicsState()

    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconRenderer", code: 2)
    }
    try data.write(to: url)
}

let icons: [(String, String, Int)] = [
    ("icp4", "icon_16x16.png", 16),
    ("icp5", "icon_16x16@2x.png", 32),
    ("icp5", "icon_32x32.png", 32),
    ("icp6", "icon_32x32@2x.png", 64),
    ("ic07", "icon_128x128.png", 128),
    ("ic08", "icon_128x128@2x.png", 256),
    ("ic08", "icon_256x256.png", 256),
    ("ic09", "icon_256x256@2x.png", 512),
    ("ic09", "icon_512x512.png", 512),
    ("ic10", "icon_512x512@2x.png", 1024)
]

try writePNG(size: 1024, to: resources.appendingPathComponent("AppIcon.png"))
for (_, filename, size) in icons {
    try writePNG(size: size, to: iconset.appendingPathComponent(filename))
}

func chunk(code: String, data: Data) -> Data {
    var out = Data(code.utf8)
    var length = UInt32(data.count + 8).bigEndian
    out.append(Data(bytes: &length, count: 4))
    out.append(data)
    return out
}

let icnsChunks = [
    ("icp4", "icon_16x16.png"),
    ("icp5", "icon_32x32.png"),
    ("icp6", "icon_32x32@2x.png"),
    ("ic07", "icon_128x128.png"),
    ("ic08", "icon_256x256.png"),
    ("ic09", "icon_512x512.png"),
    ("ic10", "icon_512x512@2x.png")
].map { code, filename in
    chunk(code: code, data: try! Data(contentsOf: iconset.appendingPathComponent(filename)))
}

var icns = Data("icns".utf8)
var length = UInt32(8 + icnsChunks.reduce(0) { $0 + $1.count }).bigEndian
icns.append(Data(bytes: &length, count: 4))
for item in icnsChunks {
    icns.append(item)
}
try icns.write(to: resources.appendingPathComponent("AppIcon.icns"))
