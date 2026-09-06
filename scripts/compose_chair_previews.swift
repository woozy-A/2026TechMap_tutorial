#!/usr/bin/env swift
import AppKit
import ImageIO

// Real Simulator pixels only: crop, uniform scale and label. No UI retouching.
// Source captures: iPhone 17 Pro, iOS 26.5, 1206 × 2622 pixels.
guard CommandLine.arguments.count == 3 else {
    fatalError("Usage: swift compose_chair_previews.swift CAPTURE_DIR OUTPUT_DIR")
}
let input = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])
let canvas = NSSize(width: 1440, height: 900)
let overview = CGRect(x: 48, y: 380, width: 1110, height: 970)
let selection = CGRect(x: 48, y: 2045, width: 1110, height: 295)
let rotateButton = CGRect(x: 48, y: 2379, width: 1110, height: 114)

func crop(_ name: String, _ rect: CGRect) throws -> NSImage {
    let url = input.appendingPathComponent(name + ".png")
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
          image.width == 1206, image.height == 2622,
          CGRect(x: 0, y: 0, width: image.width, height: image.height).contains(rect),
          let cropped = image.cropping(to: rect) else {
        fatalError("Unexpected capture size or crop: \(url.path)")
    }
    return NSImage(cgImage: cropped, size: rect.size)
}

func draw(_ image: NSImage, in rect: NSRect) {
    let scale = min(rect.width / image.size.width, rect.height / image.size.height)
    let size = NSSize(width: image.size.width * scale, height: image.size.height * scale)
    image.draw(in: NSRect(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2,
                         width: size.width, height: size.height),
               from: .zero, operation: .sourceOver, fraction: 1)
}

func label(_ text: String, x: CGFloat, y: CGFloat, width: CGFloat, size: CGFloat = 34) {
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    (text as NSString).draw(in: NSRect(x: x, y: y, width: width, height: 52),
        withAttributes: [.font: NSFont.systemFont(ofSize: size, weight: .semibold),
                         .foregroundColor: NSColor(calibratedWhite: 0.22, alpha: 1),
                         .paragraphStyle: style])
}

func compose(_ filename: String, left: String, right: String?, controls: Bool = false) throws {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1440, pixelsHigh: 900,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSGraphicsContext.current?.imageInterpolation = .high
    NSColor.white.setFill()
    NSRect(origin: .zero, size: canvas).fill()
    label(right == nil ? "3D Overview" : (left == "chair-before" ? "Before · Box" : "Before · 0°"),
          x: 48, y: 778, width: 648)
    label(right == nil ? (controls ? "Selection & Rotation" : "Selected Object") :
          (right == "chair-replaced" ? "After · Chair v2" : "After · 90°"),
          x: 744, y: 778, width: 648)
    try draw(crop(left, overview), in: NSRect(x: 48, y: 106, width: 648, height: 636))
    if let right {
        try draw(crop(right, overview), in: NSRect(x: 744, y: 106, width: 648, height: 636))
    } else {
        try draw(crop(left, selection), in: NSRect(x: 744, y: 360, width: 648, height: 210))
        if controls {
            try draw(crop(left, rotateButton), in: NSRect(x: 744, y: 220, width: 648, height: 90))
        }
    }
    label("Actual Simulator Capture · Original Office Chair v2", x: 48, y: 25, width: 1344, size: 22)
    NSGraphicsContext.restoreGraphicsState()
    try bitmap.representation(using: .png, properties: [:])!.write(to: output.appendingPathComponent(filename))
    print(filename)
}

try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
try compose("v6-section5-before-after.png", left: "chair-before", right: "chair-replaced")
try compose("v6-bonus-before-after.png", left: "chair-replaced", right: "chair-rotated-90")
try compose("v6-bonus-rotation-ready.png", left: "chair-replaced", right: nil, controls: true)
try compose("v6-goal-object-explorer.png", left: "chair-replaced", right: nil)
