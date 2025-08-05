import Foundation

/// An enum describing failures that can occur when converting images to model content data.
public enum ImageConversionError: Error {
  /// The image (the receiver of the call `toModelContentParts()`) was invalid.
  case invalidUnderlyingImage

  /// A valid image destination could not be allocated.
  case couldNotAllocateDestination

  /// JPEG image data conversion failed.
  case couldNotConvertToJPEG
}
