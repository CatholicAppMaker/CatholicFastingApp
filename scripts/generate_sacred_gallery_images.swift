#!/usr/bin/env swift
import AppKit

let assetsRoot = URL(
    fileURLWithPath: "/Users/kevpierce/Desktop/CatholicFastingApp/CatholicFastingApp/Assets.xcassets",
    isDirectory: true)
let canvas = CGSize(width: 1600, height: 1000)

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> NSColor {
    NSColor(calibratedRed: r / 255, green: g / 255, blue: b / 255, alpha: a)
}

func makeRep() -> NSBitmapImageRep {
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
        bitsPerPixel: 0)!
}

func writeAsset(name: String, fileName: String, draw: () -> Void) throws {
    let imageSetURL = assetsRoot.appendingPathComponent("\(name).imageset", isDirectory: true)
    try FileManager.default.createDirectory(at: imageSetURL, withIntermediateDirectories: true)

    let rep = makeRep()
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    draw()
    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "SacredImageGenerator", code: 1)
    }
    try pngData.write(to: imageSetURL.appendingPathComponent(fileName))

    let contents = """
    {
      "images" : [
        {
          "filename" : "\(fileName)",
          "idiom" : "universal",
          "scale" : "1x"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    try contents.write(
        to: imageSetURL.appendingPathComponent("Contents.json"),
        atomically: true,
        encoding: .utf8)
}

func backgroundGradient(_ top: NSColor, _ bottom: NSColor) {
    let gradient = NSGradient(starting: top, ending: bottom)!
    gradient.draw(
        in: NSBezierPath(rect: CGRect(origin: .zero, size: canvas)),
        angle: -90)
}

func drawHalo(center: CGPoint, outer: CGFloat, inner: CGFloat) {
    color(247, 221, 164, 0.65).setFill()
    NSBezierPath(ovalIn: CGRect(x: center.x - outer, y: center.y - outer, width: outer * 2, height: outer * 2))
        .fill()
    color(255, 246, 226, 0.95).setFill()
    NSBezierPath(ovalIn: CGRect(x: center.x - inner, y: center.y - inner, width: inner * 2, height: inner * 2))
        .fill()
}

func drawCross(center: CGPoint, size: CGSize, color crossColor: NSColor) {
    crossColor.setFill()
    NSBezierPath(
        roundedRect: CGRect(
            x: center.x - size.width * 0.12,
            y: center.y - size.height * 0.5,
            width: size.width * 0.24,
            height: size.height),
        xRadius: 16,
        yRadius: 16).fill()
    NSBezierPath(
        roundedRect: CGRect(
            x: center.x - size.width * 0.45,
            y: center.y - size.height * 0.08,
            width: size.width * 0.9,
            height: size.height * 0.2),
        xRadius: 16,
        yRadius: 16).fill()
}

func drawStars(count: Int, yMin: CGFloat, yMax: CGFloat) {
    color(255, 241, 212, 0.78).setFill()
    for i in 0 ..< count {
        let x = CGFloat(80 + (i * 137) % 1440)
        let y = yMin + CGFloat((i * 53) % Int(yMax - yMin))
        NSBezierPath(ovalIn: CGRect(x: x, y: y, width: 4, height: 4)).fill()
    }
}

do {
    try writeAsset(name: "SacredCathedralLight", fileName: "cathedral-light.png") {
        backgroundGradient(color(35, 34, 74), color(88, 69, 55))
        drawHalo(center: CGPoint(x: 800, y: 630), outer: 220, inner: 152)
        color(39, 28, 24, 0.82).setFill()
        NSBezierPath(roundedRect: CGRect(x: 380, y: 150, width: 840, height: 430), xRadius: 26, yRadius: 26)
            .fill()
        color(210, 173, 116, 0.82).setFill()
        for i in 0 ..< 6 {
            let x = 460 + CGFloat(i) * 120
            NSBezierPath(roundedRect: CGRect(x: x, y: 250, width: 72, height: 230), xRadius: 28, yRadius: 28).fill()
        }
        drawCross(center: CGPoint(x: 800, y: 690), size: CGSize(width: 180, height: 240), color: color(236, 201, 141))
        drawStars(count: 36, yMin: 700, yMax: 980)
    }

    try writeAsset(name: "SacredAshWednesday", fileName: "ash-wednesday.png") {
        backgroundGradient(color(54, 51, 50), color(119, 102, 86))
        color(43, 40, 41, 0.92).setFill()
        NSBezierPath(ovalIn: CGRect(x: 500, y: 180, width: 600, height: 710)).fill()
        color(193, 179, 159).setFill()
        NSBezierPath(ovalIn: CGRect(x: 620, y: 530, width: 84, height: 84)).fill()
        NSBezierPath(ovalIn: CGRect(x: 892, y: 530, width: 84, height: 84)).fill()
        drawCross(center: CGPoint(x: 800, y: 430), size: CGSize(width: 290, height: 360), color: color(171, 163, 153, 0.95))
        color(219, 207, 191, 0.72).setStroke()
        let ring = NSBezierPath(ovalIn: CGRect(x: 558, y: 220, width: 484, height: 634))
        ring.lineWidth = 10
        ring.stroke()
    }

    try writeAsset(name: "SacredDesertPilgrimage", fileName: "desert-pilgrimage.png") {
        backgroundGradient(color(85, 58, 42), color(200, 157, 99))
        color(236, 198, 128, 0.38).setFill()
        NSBezierPath(ovalIn: CGRect(x: 560, y: 590, width: 480, height: 300)).fill()
        color(116, 82, 55).setFill()
        NSBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 1600, height: 360), xRadius: 0, yRadius: 0).fill()
        color(89, 66, 46).setFill()
        let dune = NSBezierPath()
        dune.move(to: CGPoint(x: 0, y: 340))
        dune.curve(to: CGPoint(x: 1600, y: 290), controlPoint1: CGPoint(x: 400, y: 490), controlPoint2: CGPoint(x: 1200, y: 220))
        dune.line(to: CGPoint(x: 1600, y: 0))
        dune.line(to: CGPoint(x: 0, y: 0))
        dune.close()
        dune.fill()
        drawCross(center: CGPoint(x: 1120, y: 520), size: CGSize(width: 150, height: 340), color: color(56, 40, 28))
        color(245, 222, 172, 0.75).setFill()
        for i in 0 ..< 7 {
            NSBezierPath(ovalIn: CGRect(x: 180 + CGFloat(i) * 180, y: 720 + CGFloat((i % 2) * 28), width: 6, height: 6))
                .fill()
        }
    }

    try writeAsset(name: "SacredScriptureCandle", fileName: "scripture-candle.png") {
        backgroundGradient(color(34, 28, 48), color(82, 58, 40))
        color(192, 150, 95).setFill()
        NSBezierPath(roundedRect: CGRect(x: 360, y: 180, width: 880, height: 530), xRadius: 34, yRadius: 34).fill()
        color(232, 214, 184).setFill()
        NSBezierPath(roundedRect: CGRect(x: 420, y: 250, width: 760, height: 400), xRadius: 28, yRadius: 28).fill()
        color(177, 149, 112).setStroke()
        let seam = NSBezierPath()
        seam.move(to: CGPoint(x: 800, y: 252))
        seam.line(to: CGPoint(x: 800, y: 648))
        seam.lineWidth = 4
        seam.stroke()
        color(250, 214, 131).setFill()
        NSBezierPath(roundedRect: CGRect(x: 1180, y: 360, width: 70, height: 240), xRadius: 22, yRadius: 22).fill()
        color(255, 239, 180, 0.94).setFill()
        NSBezierPath(ovalIn: CGRect(x: 1162, y: 580, width: 106, height: 126)).fill()
        color(255, 176, 64, 0.8).setFill()
        NSBezierPath(ovalIn: CGRect(x: 1188, y: 610, width: 54, height: 74)).fill()
    }

    try writeAsset(name: "SacredPalmSunday", fileName: "palm-sunday.png") {
        backgroundGradient(color(29, 71, 62), color(125, 158, 87))
        color(221, 192, 133, 0.9).setFill()
        for i in 0 ..< 8 {
            let path = NSBezierPath()
            path.move(to: CGPoint(x: 800, y: 260))
            path.curve(
                to: CGPoint(x: 360 + CGFloat(i) * 150, y: 860),
                controlPoint1: CGPoint(x: 700, y: 520),
                controlPoint2: CGPoint(x: 520 + CGFloat(i) * 120, y: 680))
            path.lineWidth = 9
            path.stroke()
        }
        drawCross(center: CGPoint(x: 260, y: 270), size: CGSize(width: 140, height: 210), color: color(242, 222, 169))
        color(245, 230, 194, 0.78).setFill()
        NSBezierPath(ovalIn: CGRect(x: 1080, y: 710, width: 280, height: 180)).fill()
    }

    try writeAsset(name: "SacredChaliceVine", fileName: "chalice-vine.png") {
        backgroundGradient(color(49, 21, 37), color(121, 45, 58))
        color(245, 212, 142, 0.93).setFill()
        NSBezierPath(roundedRect: CGRect(x: 690, y: 160, width: 220, height: 140), xRadius: 36, yRadius: 36).fill()
        NSBezierPath(roundedRect: CGRect(x: 735, y: 290, width: 130, height: 290), xRadius: 22, yRadius: 22).fill()
        NSBezierPath(roundedRect: CGRect(x: 620, y: 540, width: 360, height: 90), xRadius: 40, yRadius: 40).fill()
        color(83, 140, 74, 0.92).setStroke()
        for i in 0 ..< 4 {
            let vine = NSBezierPath()
            vine.move(to: CGPoint(x: 400, y: 220 + CGFloat(i) * 170))
            vine.curve(
                to: CGPoint(x: 1180, y: 280 + CGFloat(i) * 140),
                controlPoint1: CGPoint(x: 620, y: 360 + CGFloat(i) * 80),
                controlPoint2: CGPoint(x: 980, y: 100 + CGFloat(i) * 110))
            vine.lineWidth = 8
            vine.stroke()
        }
        color(104, 180, 89, 0.88).setFill()
        for i in 0 ..< 16 {
            let x = CGFloat(360 + (i * 73) % 870)
            let y = CGFloat(170 + (i * 97) % 640)
            NSBezierPath(ovalIn: CGRect(x: x, y: y, width: 30, height: 20)).fill()
        }
    }

    print("Generated 6 sacred gallery assets in \(assetsRoot.path)")
} catch {
    fputs("Failed to generate sacred gallery assets: \(error)\n", stderr)
    exit(1)
}
