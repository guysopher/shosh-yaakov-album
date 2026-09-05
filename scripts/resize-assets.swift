import CoreGraphics
import Foundation
import ImageIO

enum ResizeError: Error, CustomStringConvertible {
    case usage
    case unreadable(String)
    case unwritable(String)

    var description: String {
        switch self {
        case .usage:
            return "Usage: resize-assets.swift <album-directory> <site-directory>"
        case .unreadable(let path):
            return "Could not read image: \(path)"
        case .unwritable(let path):
            return "Could not write image: \(path)"
        }
    }
}

func resizedImage(from input: URL, width targetWidth: Int) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
          let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
          let sourceWidth = properties[kCGImagePropertyPixelWidth] as? Double,
          let sourceHeight = properties[kCGImagePropertyPixelHeight] as? Double else {
        throw ResizeError.unreadable(input.path)
    }

    let targetHeight = Int((Double(targetWidth) * sourceHeight / sourceWidth).rounded())
    let maximumDimension = max(targetWidth, targetHeight)
    let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maximumDimension,
        kCGImageSourceShouldCacheImmediately: true,
    ]
    guard let resized = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
        throw ResizeError.unreadable(input.path)
    }

    return resized
}

func writeJPEG(_ image: CGImage, to output: URL, quality: Double) throws {
    guard let destination = CGImageDestinationCreateWithURL(output as CFURL, "public.jpeg" as CFString, 1, nil) else {
        throw ResizeError.unwritable(output.path)
    }
    let outputOptions: [CFString: Any] = [
        kCGImageDestinationLossyCompressionQuality: quality,
    ]
    CGImageDestinationAddImage(destination, image, outputOptions as CFDictionary)
    guard CGImageDestinationFinalize(destination) else {
        throw ResizeError.unwritable(output.path)
    }
}

func resizeJPEG(from input: URL, to output: URL, width targetWidth: Int, quality: Double) throws {
    try writeJPEG(resizedImage(from: input, width: targetWidth), to: output, quality: quality)
}

do {
    guard CommandLine.arguments.count == 3 else { throw ResizeError.usage }
    let album = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    let site = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)

    let covers = album.appendingPathComponent("output/covers")
    let webCovers = site.appendingPathComponent("assets/covers")
    try resizeJPEG(
        from: covers.appendingPathComponent("front-cover-3636x3755.jpg"),
        to: webCovers.appendingPathComponent("front-cover.jpg"),
        width: 1400,
        quality: 0.84
    )
    try resizeJPEG(
        from: covers.appendingPathComponent("back-cover-3636x3755.jpg"),
        to: webCovers.appendingPathComponent("back-cover.jpg"),
        width: 1400,
        quality: 0.84
    )

    for number in 1...24 {
        let padded = String(format: "%02d", number)
        let spread = try resizedImage(
            from: album.appendingPathComponent("output/spreads/spread-\(padded).jpg"),
            width: 2400
        )
        let halfWidth = spread.width / 2
        guard let left = spread.cropping(to: CGRect(x: 0, y: 0, width: halfWidth, height: spread.height)),
              let right = spread.cropping(to: CGRect(x: halfWidth, y: 0, width: spread.width - halfWidth, height: spread.height)) else {
            throw ResizeError.unreadable("spread-\(padded).jpg")
        }
        try writeJPEG(left, to: site.appendingPathComponent("assets/pages/\(padded)-left.jpg"), quality: 0.86)
        try writeJPEG(right, to: site.appendingPathComponent("assets/pages/\(padded)-right.jpg"), quality: 0.86)
    }
} catch {
    FileHandle.standardError.write(Data("\(error)\n".utf8))
    exit(1)
}
