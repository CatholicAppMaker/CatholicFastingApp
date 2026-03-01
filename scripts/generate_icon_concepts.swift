#!/usr/bin/env swift
import AppKit

let outputDir = URL(fileURLWithPath: "/Users/kevpierce/Desktop/CatholicFastingApp/design/icon-concepts", isDirectory: true)
try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

let size = CGSize(width: 1024, height: 1024)

func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> NSColor {
    NSColor(calibratedRed: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

func makeRep() -> NSBitmapImageRep {
    NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
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

func writePNG(_ rep: NSBitmapImageRep, _ name: String) throws {
    let url = outputDir.appendingPathComponent(name)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "icon-concepts", code: 1)
    }
    try data.write(to: url)
}

func fillRoundedCard(_ rect: CGRect, radius: CGFloat) {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

func sacredHeart() throws {
    let rep = makeRep()
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    rgba(113, 20, 25).setFill()
    fillRoundedCard(CGRect(origin: .zero, size: size), radius: 226)

    let glow = NSBezierPath(ovalIn: CGRect(x: 120, y: 230, width: 784, height: 684))
    rgba(255, 198, 101, 0.33).setFill()
    glow.fill()

    let heart = NSBezierPath()
    heart.move(to: CGPoint(x: 512, y: 328))
    heart.curve(to: CGPoint(x: 282, y: 588), controlPoint1: CGPoint(x: 360, y: 390), controlPoint2: CGPoint(x: 282, y: 500))
    heart.curve(to: CGPoint(x: 448, y: 758), controlPoint1: CGPoint(x: 282, y: 706), controlPoint2: CGPoint(x: 360, y: 758))
    heart.curve(to: CGPoint(x: 512, y: 682), controlPoint1: CGPoint(x: 480, y: 758), controlPoint2: CGPoint(x: 512, y: 722))
    heart.curve(to: CGPoint(x: 576, y: 758), controlPoint1: CGPoint(x: 512, y: 722), controlPoint2: CGPoint(x: 544, y: 758))
    heart.curve(to: CGPoint(x: 742, y: 588), controlPoint1: CGPoint(x: 664, y: 758), controlPoint2: CGPoint(x: 742, y: 706))
    heart.curve(to: CGPoint(x: 512, y: 328), controlPoint1: CGPoint(x: 742, y: 500), controlPoint2: CGPoint(x: 664, y: 390))
    heart.close()
    rgba(210, 32, 50).setFill()
    heart.fill()

    let crown = NSBezierPath()
    crown.appendArc(withCenter: CGPoint(x: 512, y: 645), radius: 252, startAngle: 205, endAngle: -25, clockwise: false)
    crown.lineWidth = 36
    rgba(47, 114, 70).setStroke()
    crown.stroke()

    rgba(248, 228, 153).setFill()
    for idx in 0 ..< 12 {
        let angle = (CGFloat(idx) / 12.0) * (.pi * 1.2) + .pi * 0.95
        let x = 512 + cos(angle) * 252
        let y = 645 + sin(angle) * 252
        NSBezierPath(ovalIn: CGRect(x: x - 11, y: y - 11, width: 22, height: 22)).fill()
    }

    let flame = NSBezierPath()
    flame.move(to: CGPoint(x: 512, y: 848))
    flame.curve(to: CGPoint(x: 442, y: 736), controlPoint1: CGPoint(x: 462, y: 814), controlPoint2: CGPoint(x: 432, y: 786))
    flame.curve(to: CGPoint(x: 512, y: 676), controlPoint1: CGPoint(x: 450, y: 698), controlPoint2: CGPoint(x: 486, y: 676))
    flame.curve(to: CGPoint(x: 582, y: 736), controlPoint1: CGPoint(x: 538, y: 676), controlPoint2: CGPoint(x: 574, y: 698))
    flame.curve(to: CGPoint(x: 512, y: 848), controlPoint1: CGPoint(x: 592, y: 786), controlPoint2: CGPoint(x: 562, y: 814))
    flame.close()
    rgba(255, 188, 62).setFill()
    flame.fill()

    let cross = NSBezierPath(roundedRect: CGRect(x: 486, y: 824, width: 52, height: 140), xRadius: 12, yRadius: 12)
    rgba(255, 232, 189).setFill()
    cross.fill()
    NSBezierPath(roundedRect: CGRect(x: 446, y: 870, width: 132, height: 44), xRadius: 12, yRadius: 12).fill()

    NSGraphicsContext.restoreGraphicsState()
    try writePNG(rep, "icon-concept-sacred-heart.png")
}

func chiRho() throws {
    let rep = makeRep()
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let center = CGPoint(x: 512, y: 512)
    for i in 0 ..< 12 {
        let t = CGFloat(i) / 11.0
        rgba(8 + 38 * t, 43 + 67 * t, 87 + 53 * t).setFill()
        NSBezierPath(rect: CGRect(x: 0, y: CGFloat(i) * 92, width: 1024, height: 92)).fill()
    }

    let halo = NSBezierPath(ovalIn: CGRect(x: 146, y: 146, width: 732, height: 732))
    rgba(236, 200, 118, 0.26).setFill()
    halo.fill()

    let ring = NSBezierPath(ovalIn: CGRect(x: 208, y: 208, width: 608, height: 608))
    ring.lineWidth = 26
    rgba(240, 208, 132).setStroke()
    ring.stroke()

    let pStem = NSBezierPath(roundedRect: CGRect(x: 472, y: 242, width: 80, height: 560), xRadius: 24, yRadius: 24)
    rgba(249, 236, 191).setFill()
    pStem.fill()

    let pLoop = NSBezierPath(ovalIn: CGRect(x: 512, y: 476, width: 252, height: 240))
    pLoop.lineWidth = 66
    rgba(249, 236, 191).setStroke()
    pLoop.stroke()

    let x1 = NSBezierPath(roundedRect: CGRect(x: 358, y: 332, width: 300, height: 58), xRadius: 16, yRadius: 16)
    let x2 = NSBezierPath(roundedRect: CGRect(x: 356, y: 330, width: 300, height: 58), xRadius: 16, yRadius: 16)
    let transform1 = AffineTransform(rotationByDegrees: 44)
    var t1 = transform1
    t1.translate(x: center.x - 512, y: center.y - 512)
    x1.transform(using: t1)
    rgba(249, 236, 191).setFill()
    x1.fill()
    let transform2 = AffineTransform(rotationByDegrees: -44)
    var t2 = transform2
    t2.translate(x: center.x - 512, y: center.y - 512)
    x2.transform(using: t2)
    x2.fill()

    let alpha = NSBezierPath()
    let omega = NSBezierPath()
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 94, weight: .bold),
        .foregroundColor: rgba(249, 236, 191),
    ]
    "Α".draw(at: CGPoint(x: 250, y: 186), withAttributes: attrs)
    "Ω".draw(at: CGPoint(x: 692, y: 186), withAttributes: attrs)
    _ = alpha
    _ = omega

    NSGraphicsContext.restoreGraphicsState()
    try writePNG(rep, "icon-concept-chi-rho.png")
}

func rosaryCross() throws {
    let rep = makeRep()
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    rgba(33, 41, 67).setFill()
    fillRoundedCard(CGRect(origin: .zero, size: size), radius: 226)

    let mandorla = NSBezierPath(ovalIn: CGRect(x: 140, y: 176, width: 744, height: 744))
    rgba(164, 140, 84, 0.21).setFill()
    mandorla.fill()

    rgba(220, 199, 145).setFill()
    let vertical = NSBezierPath(roundedRect: CGRect(x: 458, y: 276, width: 108, height: 480), xRadius: 30, yRadius: 30)
    vertical.fill()
    let horizontal = NSBezierPath(roundedRect: CGRect(x: 316, y: 462, width: 392, height: 96), xRadius: 30, yRadius: 30)
    horizontal.fill()

    let beadColor = rgba(235, 218, 177)
    beadColor.setFill()
    let center = CGPoint(x: 512, y: 540)
    let radius: CGFloat = 310
    for i in 0 ..< 24 {
        let angle = (CGFloat(i) / 24.0) * .pi * 2.0 + .pi * 0.18
        let x = center.x + cos(angle) * radius
        let y = center.y + sin(angle) * radius
        NSBezierPath(ovalIn: CGRect(x: x - 16, y: y - 16, width: 32, height: 32)).fill()
    }

    let pendant = NSBezierPath(roundedRect: CGRect(x: 486, y: 136, width: 52, height: 152), xRadius: 16, yRadius: 16)
    beadColor.setFill()
    pendant.fill()
    NSBezierPath(roundedRect: CGRect(x: 448, y: 186, width: 128, height: 44), xRadius: 14, yRadius: 14).fill()

    NSGraphicsContext.restoreGraphicsState()
    try writePNG(rep, "icon-concept-rosary-cross.png")
}

do {
    try sacredHeart()
    try chiRho()
    try rosaryCross()
    print("Wrote icon concepts to \(outputDir.path)")
} catch {
    fputs("Failed: \(error)\n", stderr)
    exit(1)
}
