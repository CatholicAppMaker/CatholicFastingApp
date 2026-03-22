#!/usr/bin/env swift
import AppKit

struct Palette {
    let background: NSColor
    let glow: NSColor
    let ray: NSColor
    let host: NSColor
}

let projectRoot = URL(fileURLWithPath: "/Users/kevpierce/Desktop/CatholicFastingApp")
let assetsRoot = projectRoot.appendingPathComponent("CatholicFastingApp/Assets.xcassets", isDirectory: true)

let iconSets: [(name: String, palette: Palette)] = [
    ("AppIcon.appiconset", Palette(
        background: NSColor(calibratedRed: 32 / 255, green: 23 / 255, blue: 51 / 255, alpha: 1),
        glow: NSColor(calibratedRed: 248 / 255, green: 218 / 255, blue: 139 / 255, alpha: 0.24),
        ray: NSColor(calibratedRed: 248 / 255, green: 218 / 255, blue: 139 / 255, alpha: 1),
        host: NSColor(calibratedRed: 253 / 255, green: 247 / 255, blue: 223 / 255, alpha: 1))),
    ("AppIconAdvent.appiconset", Palette(
        background: NSColor(calibratedRed: 74 / 255, green: 50 / 255, blue: 118 / 255, alpha: 1),
        glow: NSColor(calibratedRed: 214 / 255, green: 179 / 255, blue: 118 / 255, alpha: 0.24),
        ray: NSColor(calibratedRed: 236 / 255, green: 198 / 255, blue: 128 / 255, alpha: 1),
        host: NSColor(calibratedRed: 250 / 255, green: 244 / 255, blue: 226 / 255, alpha: 1))),
    ("AppIconChristmas.appiconset", Palette(
        background: NSColor(calibratedRed: 22 / 255, green: 86 / 255, blue: 63 / 255, alpha: 1),
        glow: NSColor(calibratedRed: 254 / 255, green: 226 / 255, blue: 150 / 255, alpha: 0.24),
        ray: NSColor(calibratedRed: 250 / 255, green: 215 / 255, blue: 128 / 255, alpha: 1),
        host: NSColor(calibratedRed: 255 / 255, green: 250 / 255, blue: 232 / 255, alpha: 1))),
    ("AppIconLent.appiconset", Palette(
        background: NSColor(calibratedRed: 41 / 255, green: 27 / 255, blue: 68 / 255, alpha: 1),
        glow: NSColor(calibratedRed: 183 / 255, green: 147 / 255, blue: 88 / 255, alpha: 0.22),
        ray: NSColor(calibratedRed: 206 / 255, green: 166 / 255, blue: 94 / 255, alpha: 1),
        host: NSColor(calibratedRed: 242 / 255, green: 230 / 255, blue: 201 / 255, alpha: 1))),
    ("AppIconEaster.appiconset", Palette(
        background: NSColor(calibratedRed: 244 / 255, green: 247 / 255, blue: 252 / 255, alpha: 1),
        glow: NSColor(calibratedRed: 252 / 255, green: 220 / 255, blue: 138 / 255, alpha: 0.30),
        ray: NSColor(calibratedRed: 232 / 255, green: 185 / 255, blue: 92 / 255, alpha: 1),
        host: NSColor(calibratedRed: 255 / 255, green: 255 / 255, blue: 251 / 255, alpha: 1))),
]

func iconPixels(from filename: String) -> Int? {
    if filename == "icon-1024.png" { return 1024 }
    guard let dash = filename.firstIndex(of: "-") else { return nil }
    let tail = filename[filename.index(after: dash)...]
    let valueText = tail.split(separator: "@").first?.split(separator: ".png").first ?? ""
    let pointsText = valueText.split(separator: "x").first ?? ""
    guard let points = Double(pointsText) else { return nil }
    var scale = 1.0
    if let at = filename.firstIndex(of: "@") {
        let suffix = filename[filename.index(after: at)...]
        if suffix.hasPrefix("2x") { scale = 2.0 }
        if suffix.hasPrefix("3x") { scale = 3.0 }
    }
    return Int((points * scale).rounded())
}

func renderMonstrance(size: Int, palette: Palette) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bitmapFormat: [],
        bytesPerRow: 0,
        bitsPerPixel: 0)!

    let scale = CGFloat(size) / 1024.0
    let smallMode = size <= 120
    let tinyMode = size <= 60
    let rayCount = tinyMode ? 10 : (smallMode ? 12 : 16)
    let rayInner: CGFloat = (tinyMode ? 160 : 140) * scale
    let rayOuter: CGFloat = (tinyMode ? 292 : (smallMode ? 304 : 300)) * scale
    let raySpread: CGFloat = tinyMode ? 0.11 : (smallMode ? 0.09 : 0.07)
    let ringLineWidth: CGFloat = max((tinyMode ? 36 : (smallMode ? 30 : 26)) * scale, tinyMode ? 2.2 : 1.2)
    let stemCorner: CGFloat = max((tinyMode ? 22 : 18) * scale, 1.2)
    let footCorner: CGFloat = max((tinyMode ? 34 : 30) * scale, 1.2)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    palette.background.setFill()
    NSBezierPath(
        roundedRect: CGRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size)),
        xRadius: 220 * scale,
        yRadius: 220 * scale).fill()

    palette.glow.setFill()
    NSBezierPath(ovalIn: CGRect(x: 182 * scale, y: 282 * scale, width: 660 * scale, height: 660 * scale)).fill()

    let center = CGPoint(x: 512 * scale, y: 592 * scale)
    palette.ray.setFill()
    for i in 0 ..< rayCount {
        let angle = CGFloat(i) * (.pi * 2 / CGFloat(rayCount))
        let path = NSBezierPath()
        let p1 = CGPoint(x: center.x + cos(angle - raySpread) * rayInner, y: center.y + sin(angle - raySpread) * rayInner)
        let p2 = CGPoint(x: center.x + cos(angle) * rayOuter, y: center.y + sin(angle) * rayOuter)
        let p3 = CGPoint(x: center.x + cos(angle + raySpread) * rayInner, y: center.y + sin(angle + raySpread) * rayInner)
        path.move(to: p1)
        path.line(to: p2)
        path.line(to: p3)
        path.close()
        path.fill()
    }

    palette.host.setFill()
    NSBezierPath(ovalIn: CGRect(x: 362 * scale, y: 442 * scale, width: 300 * scale, height: 300 * scale)).fill()

    palette.ray.setStroke()
    let hostRing = NSBezierPath(ovalIn: CGRect(x: 334 * scale, y: 414 * scale, width: 356 * scale, height: 356 * scale))
    hostRing.lineWidth = ringLineWidth
    hostRing.stroke()

    palette.ray.setFill()
    NSBezierPath(
        roundedRect: CGRect(x: 470 * scale, y: 220 * scale, width: 84 * scale, height: 230 * scale),
        xRadius: stemCorner,
        yRadius: stemCorner).fill()
    NSBezierPath(
        roundedRect: CGRect(x: 388 * scale, y: 170 * scale, width: 248 * scale, height: 62 * scale),
        xRadius: stemCorner,
        yRadius: stemCorner).fill()
    NSBezierPath(
        roundedRect: CGRect(x: 330 * scale, y: 92 * scale, width: 364 * scale, height: 74 * scale),
        xRadius: footCorner,
        yRadius: footCorner).fill()

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

for set in iconSets {
    let setURL = assetsRoot.appendingPathComponent(set.name, isDirectory: true)
    let files = (try? FileManager.default.contentsOfDirectory(atPath: setURL.path)) ?? []
    for file in files where file.hasSuffix(".png") {
        guard let px = iconPixels(from: file) else { continue }
        let rep = renderMonstrance(size: px, palette: set.palette)
        guard let data = rep.representation(using: .png, properties: [:]) else { continue }
        try data.write(to: setURL.appendingPathComponent(file))
    }
}

print("Generated Monstrance icons across primary + seasonal app icon sets.")
