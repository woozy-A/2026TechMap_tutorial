#!/usr/bin/env swift

import AppKit
import Foundation

// Deterministically composes DocC result previews from verified Simulator captures.
// It only crops and uniformly scales source pixels; it never retouches UI content.

private struct TopLeftRect {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

private enum ScalingMode {
    case fit
    case fill
}

private struct Crop {
    let sourceName: String
    let rect: TopLeftRect
    let scalingMode: ScalingMode
}

private struct Preview {
    let outputName: String
    let left: Crop
    let right: Crop
}

private let canvasSize = NSSize(width: 1440, height: 900)
private let panelTopLeftRects = [
    TopLeftRect(x: 48, y: 154, width: 648, height: 690),
    TopLeftRect(x: 744, y: 154, width: 648, height: 690)
]

private let previews = [
    Preview(
        outputName: "v6-section1-sample-loaded.png",
        left: Crop(
            sourceName: "01-sample-room-loaded.png",
            rect: TopLeftRect(x: 39, y: 185, width: 326, height: 290),
            scalingMode: .fit
        ),
        right: Crop(
            sourceName: "01-sample-room-loaded.png",
            rect: TopLeftRect(x: 39, y: 485, width: 326, height: 165),
            scalingMode: .fill
        )
    ),
    Preview(
        outputName: "v6-section3-object-selected.png",
        left: Crop(
            sourceName: "03-chair2-selected.png",
            rect: TopLeftRect(x: 39, y: 185, width: 326, height: 290),
            scalingMode: .fit
        ),
        right: Crop(
            sourceName: "04-chair2-highlight.png",
            rect: TopLeftRect(x: 75, y: 1380, width: 1056, height: 805),
            scalingMode: .fit
        )
    ),
    Preview(
        outputName: "v6-section4-all-boxes.png",
        left: Crop(
            sourceName: "04-all-boxes.png",
            rect: TopLeftRect(x: 39, y: 185, width: 326, height: 290),
            scalingMode: .fit
        ),
        right: Crop(
            sourceName: "02-objects-detected.png",
            rect: TopLeftRect(x: 48, y: 1380, width: 1110, height: 910),
            scalingMode: .fit
        )
    ),
    Preview(
        outputName: "v6-section4-highlight.png",
        left: Crop(
            sourceName: "04-chair2-highlight.png",
            rect: TopLeftRect(x: 48, y: 360, width: 1110, height: 1000),
            scalingMode: .fit
        ),
        right: Crop(
            sourceName: "04-chair2-highlight.png",
            rect: TopLeftRect(x: 48, y: 1380, width: 1110, height: 800),
            scalingMode: .fit
        )
    )
]

private func bottomLeftRect(from rect: TopLeftRect, in height: CGFloat) -> NSRect {
    NSRect(x: rect.x, y: height - rect.y - rect.height, width: rect.width, height: rect.height)
}

private func loadImage(at url: URL) throws -> NSImage {
    guard let image = NSImage(contentsOf: url) else {
        throw NSError(
            domain: "PreviewComposer",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Unable to load image at \(url.path)"]
        )
    }
    return image
}

private func draw(_ crop: Crop, sourceRoot: URL, in target: TopLeftRect) throws {
    let image = try loadImage(at: sourceRoot.appendingPathComponent(crop.sourceName))
    let sourceRect = bottomLeftRect(from: crop.rect, in: image.size.height)
    let targetRect = bottomLeftRect(from: target, in: canvasSize.height)

    let widthScale = targetRect.width / sourceRect.width
    let heightScale = targetRect.height / sourceRect.height
    let scale: CGFloat
    switch crop.scalingMode {
    case .fit:
        scale = min(widthScale, heightScale)
    case .fill:
        scale = max(widthScale, heightScale)
    }

    let drawSize = NSSize(width: sourceRect.width * scale, height: sourceRect.height * scale)
    let drawRect = NSRect(
        x: targetRect.midX - drawSize.width / 2,
        y: targetRect.midY - drawSize.height / 2,
        width: drawSize.width,
        height: drawSize.height
    )

    NSGraphicsContext.current?.saveGraphicsState()
    NSBezierPath(roundedRect: targetRect, xRadius: 28, yRadius: 28).addClip()
    image.draw(
        in: drawRect,
        from: sourceRect,
        operation: .copy,
        fraction: 1,
        respectFlipped: true,
        hints: [.interpolation: NSImageInterpolation.high]
    )
    NSGraphicsContext.current?.restoreGraphicsState()
}

private func drawCenteredTitle(_ title: String, above panel: TopLeftRect) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 36, weight: .bold),
        .foregroundColor: NSColor(calibratedWhite: 0.20, alpha: 1)
    ]
    let attributedTitle = NSAttributedString(string: title, attributes: attributes)
    let size = attributedTitle.size()
    let topLeft = TopLeftRect(
        x: panel.x + (panel.width - size.width) / 2,
        y: 80,
        width: size.width,
        height: size.height
    )
    attributedTitle.draw(in: bottomLeftRect(from: topLeft, in: canvasSize.height))
}

private func compose(_ preview: Preview, sourceRoot: URL, outputRoot: URL) throws {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize.width),
        pixelsHigh: Int(canvasSize.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(
            domain: "PreviewComposer",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Unable to create output bitmap"]
        )
    }

    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(
            domain: "PreviewComposer",
            code: 3,
            userInfo: [NSLocalizedDescriptionKey: "Unable to create graphics context"]
        )
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.imageInterpolation = .high

    NSColor.white.setFill()
    NSRect(origin: .zero, size: canvasSize).fill()

    for panel in panelTopLeftRects {
        let rect = bottomLeftRect(from: panel, in: canvasSize.height)
        NSColor(calibratedWhite: 0.96, alpha: 1).setFill()
        NSBezierPath(roundedRect: rect, xRadius: 28, yRadius: 28).fill()
    }

    drawCenteredTitle("3D Overview", above: panelTopLeftRects[0])
    drawCenteredTitle("Object List", above: panelTopLeftRects[1])

    let contentRects = panelTopLeftRects.map {
        TopLeftRect(x: $0.x + 18, y: $0.y + 18, width: $0.width - 36, height: $0.height - 36)
    }
    try draw(preview.left, sourceRoot: sourceRoot, in: contentRects[0])
    try draw(preview.right, sourceRoot: sourceRoot, in: contentRects[1])

    NSGraphicsContext.restoreGraphicsState()

    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(
            domain: "PreviewComposer",
            code: 4,
            userInfo: [NSLocalizedDescriptionKey: "Unable to encode output PNG"]
        )
    }

    try FileManager.default.createDirectory(at: outputRoot, withIntermediateDirectories: true)
    try data.write(to: outputRoot.appendingPathComponent(preview.outputName), options: .atomic)
}

private let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    FileHandle.standardError.write(
        Data("Usage: swift scripts/compose_preview_images.swift SOURCE_EVIDENCE_DIR OUTPUT_IMAGES_DIR\n".utf8)
    )
    exit(64)
}

let sourceRoot = URL(fileURLWithPath: arguments[1], isDirectory: true)
let outputRoot = URL(fileURLWithPath: arguments[2], isDirectory: true)

do {
    for preview in previews {
        try compose(preview, sourceRoot: sourceRoot, outputRoot: outputRoot)
        print("Wrote \(outputRoot.appendingPathComponent(preview.outputName).path)")
    }
} catch {
    FileHandle.standardError.write(Data("Preview composition failed: \(error)\n".utf8))
    exit(1)
}
