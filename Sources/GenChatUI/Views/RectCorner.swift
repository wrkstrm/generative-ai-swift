#if canImport(SwiftUI)
struct RectCorner: OptionSet {
  let rawValue: Int

  static let topLeft = RectCorner(rawValue: 1 << 0)
  static let topRight = RectCorner(rawValue: 1 << 1)
  static let bottomLeft = RectCorner(rawValue: 1 << 2)
  static let bottomRight = RectCorner(rawValue: 1 << 3)
  static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}
#endif
