#!/usr/bin/env swift
import AppKit

let outputDir = URL(fileURLWithPath: "/Users/kevpierce/Desktop/CatholicFastingApp/design/icon-concepts", isDirectory: true)
try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

let canvas = CGSize(width: 1024, height: 1024)

func c(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> NSColor {
    NSColor(calibratedRed: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

func rep() -> NSBitmapImageRep {
    NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvas.width),
        pixelsHigh: Int(canvas.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bitmapFormat: [],
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
}

func save(_ rep: NSBitmapImageRep, _ fileName: String) throws {
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "icon-v2", code: 1)
    }
    try data.write(to: outputDir.appendingPathComponent(fileName))
}

func card(_ color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 1024, height: 1024), xRadius: 220, yRadius: 220).fill()
}

func marianMonogram() throws {
    let bitmap = rep()
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

    card(c(28, 56, 111))
    c(244, 222, 168, 0.2).setFill()
    NSBezierPath(ovalIn: CGRect(x: 150, y: 120, width: 724, height: 724)).fill()

    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 560, weight: .black),
        .foregroundColor: c(247, 233, 197),
    ]
    "M".draw(at: CGPoint(x: 250, y: 240), withAttributes: attrs)

    c(247, 233, 197).setFill()
    NSBezierPath(roundedRect: CGRect(x: 735, y: 700, width: 56, height: 190), xRadius: 12, yRadius: 12).fill()
    NSBezierPath(roundedRect: CGRect(x: 675, y: 772, width: 175, height: 56), xRadius: 12, yRadius: 12).fill()

    c(244, 214, 136).setFill()
    for i in 0 ..< 12 {
        let angle = (CGFloat(i) / 12.0) * .pi * 2.0
        let x = 512 + cos(angle) * 360
        let y = 520 + sin(angle) * 360
        NSBezierPath(ovalIn: CGRect(x: x - 12, y: y - 12, width: 24, height: 24)).fill()
    }

    NSGraphicsContext.restoreGraphicsState()
    try save(bitmap, "icon-concept2-marian-monogram.png")
}

func jerusalemCross() throws {
    let bitmap = rep()
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

    card(c(121, 32, 32))
    c(253, 239, 204).setFill()

    NSBezierPath(roundedRect: CGRect(x: 430, y: 200, width: 164, height: 624), xRadius: 28, yRadius: 28).fill()
    NSBezierPath(roundedRect: CGRect(x: 250, y: 430, width: 524, height: 164), xRadius: 28, yRadius: 28).fill()

    let smallRects = [
        CGRect(x: 182, y: 182, width: 120, height: 120),
        CGRect(x: 722, y: 182, width: 120, height: 120),
        CGRect(x: 182, y: 722, width: 120, height: 120),
        CGRect(x: 722, y: 722, width: 120, height: 120),
    ]
    for rect in smallRects {
        NSBezierPath(roundedRect: rect, xRadius: 18, yRadius: 18).fill()
    }

    c(252, 216, 145, 0.35).setStroke()
    let ring = NSBezierPath(ovalIn: CGRect(x: 130, y: 130, width: 764, height: 764))
    ring.lineWidth = 20
    ring.stroke()

    NSGraphicsContext.restoreGraphicsState()
    try save(bitmap, "icon-concept2-jerusalem-cross.png")
}

func monstrance() throws {
    let bitmap = rep()
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

    card(c(32, 23, 51))

    c(248, 218, 139).setFill()
    let hostRaysCenter = CGPoint(x: 512, y: 592)
    for i in 0 ..< 16 {
        let angle = CGFloat(i) * (.pi * 2 / 16)
        let path = NSBezierPath()
        let r1: CGFloat = 140
        let r2: CGFloat = 300
        let p1 = CGPoint(x: hostRaysCenter.x + cos(angle - 0.07) * r1, y: hostRaysCenter.y + sin(angle - 0.07) * r1)
        let p2 = CGPoint(x: hostRaysCenter.x + cos(angle) * r2, y: hostRaysCenter.y + sin(angle) * r2)
        let p3 = CGPoint(x: hostRaysCenter.x + cos(angle + 0.07) * r1, y: hostRaysCenter.y + sin(angle + 0.07) * r1)
        path.move(to: p1)
        path.line(to: p2)
        path.line(to: p3)
        path.close()
        path.fill()
    }

    c(253, 247, 223).setFill()
    NSBezierPath(ovalIn: CGRect(x: 362, y: 442, width: 300, height: 300)).fill()
    c(236, 196, 110).setStroke()
    let hostRing = NSBezierPath(ovalIn: CGRect(x: 334, y: 414, width: 356, height: 356))
    hostRing.lineWidth = 26
    hostRing.stroke()

    c(236, 196, 110).setFill()
    NSBezierPath(roundedRect: CGRect(x: 470, y: 220, width: 84, height: 230), xRadius: 18, yRadius: 18).fill()
    NSBezierPath(roundedRect: CGRect(x: 388, y: 170, width: 248, height: 62), xRadius: 20, yRadius: 20).fill()
    NSBezierPath(roundedRect: CGRect(x: 330, y: 92, width: 364, height: 74), xRadius: 30, yRadius: 30).fill()

    NSGraphicsContext.restoreGraphicsState()
    try save(bitmap, "icon-concept2-monstrance.png")
}

do {
    try marianMonogram()
    try jerusalemCross()
    try monstrance()
    print("Wrote v2 icon concepts to \(outputDir.path)")
} catch {
    fputs("Failed: \(error)\n", stderr)
    exit(1)
}
