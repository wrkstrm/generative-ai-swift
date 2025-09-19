import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif
#if canImport(CoreImage)
import CoreImage
#endif
#if canImport(ImageIO)
import ImageIO
#endif
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
private func cgImageToJPEGData(_ cgImage: CGImage) throws -> Data {
  #if canImport(ImageIO)
  let data = NSMutableData()
  guard
    let dest = CGImageDestinationCreateWithData(
      data as CFMutableData,
      UTType.jpeg.identifier as CFString,
      1,
      nil,
    )
  else {
    throw ImageConversionError.couldNotAllocateDestination
  }
  CGImageDestinationAddImage(dest, cgImage, nil)
  guard CGImageDestinationFinalize(dest) else {
    throw ImageConversionError.couldNotConvertToJPEG(cgImage)
  }
  return data as Data
  #else
  throw ImageConversionError.couldNotConvertToJPEG(cgImage)
  #endif
}

// MARK: - CGImage

#if canImport(CoreGraphics)
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension CGImage: ThrowingPartsRepresentable {
  public func tryPartsValue() throws -> [ModelContent.Part] {
    let data = try cgImageToJPEGData(self)
    return [.jpeg(data)]
  }
}
#endif

// MARK: - CIImage

#if canImport(CoreImage)
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension CIImage: ThrowingPartsRepresentable {
  public func tryPartsValue() throws -> [ModelContent.Part] {
    let context = CIContext(options: nil)
    guard let cg = context.createCGImage(self, from: extent) else {
      throw ImageConversionError.couldNotConvertToJPEG(self)
    }
    let data = try cgImageToJPEGData(cg)
    return [.jpeg(data)]
  }
}
#endif

// MARK: - NSImage (macOS)

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
@available(macOS 11.0, *)
extension NSImage: ThrowingPartsRepresentable {
  public func tryPartsValue() throws -> [ModelContent.Part] {
    // Prefer CGImage extraction
    var rect = CGRect(origin: .zero, size: size)
    if let cg = cgImage(forProposedRect: &rect, context: nil, hints: nil) {
      let data = try cgImageToJPEGData(cg)
      return [.jpeg(data)]
    }
    // Validate bitmap reps for empty images
    guard let tiff = tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let cg = rep.cgImage
    else {
      throw ImageConversionError.invalidUnderlyingImage
    }
    let data = try cgImageToJPEGData(cg)
    return [.jpeg(data)]
  }
}
#endif

// MARK: - UIImage (iOS)

#if canImport(UIKit) && !targetEnvironment(macCatalyst)
@available(iOS 15.0, macCatalyst 15.0, *)
extension UIImage: ThrowingPartsRepresentable {
  public func tryPartsValue() throws -> [ModelContent.Part] {
    // If the image cannot produce JPEG data, propagate conversion error with source image
    guard
      let cg = cgImage
        ?? CIContext().createCGImage(
          CIImage(image: self) ?? CIImage(), from: CGRect(origin: .zero, size: size),
        )
    else {
      throw ImageConversionError.couldNotConvertToJPEG(self)
    }
    let data = try cgImageToJPEGData(cg)
    return [.jpeg(data)]
  }
}
#endif
