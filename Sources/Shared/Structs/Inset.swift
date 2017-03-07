import Tailor

/// A content inset struct used for configuring layout on Spotable objects.
public struct Inset: Mappable, Equatable {

  /// The root key for the JSON dictionary.
  static let rootKey: String = String(describing: Inset.self).lowercased()

  /// A string enum use for constructing a JSON dictionary representation.
  enum Key: String {
    case top, left, bottom, right
  }

  /// Top content inset.
  var top: Double = 0.0
  /// Left content inset.
  var left: Double = 0.0
  /// Bottom content inset.
  var bottom: Double = 0.0
  /// Right content inset.
  var right: Double = 0.0

  /// A dictionary representation of the struct.
  public var dictionary: [String : Double] {
    return [
      Key.top.rawValue: self.top,
      Key.left.rawValue: self.left,
      Key.bottom.rawValue: self.bottom,
      Key.right.rawValue: self.right
    ]
  }

  /// A convenience init for initializing a content inset.
  ///
  /// - Parameters:
  ///   - top: Top content inset.
  ///   - left: Left content inset.
  ///   - bottom: Bottom content inset.
  ///   - right: Right content inset.
  public init(top: Double = 0.0, left: Double = 0.0, bottom: Double = 0.0, right: Double = 0.0) {
    self.top = top
    self.left = left
    self.bottom = bottom
    self.right = right
  }

  /// A convenience init for initializing a content inset using block syntax.
  ///
  /// - Parameter block: A mutating closure.
  public init(_ block: (inout Inset) -> Void) {
    self.init()
    block(&self)
  }

  /// A convenience init for initializing a content inset using a JSON dictionary.
  ///
  /// - Parameter map: A JSON dictionary that will be mapped into the content insets.
  public init(_ map: [String : Any]) {
    switch ComponentModel.legacyMapping {
    case true:
      self.top    <- map.property(GridableMeta.Key.contentInsetTop)
      self.left   <- map.property(GridableMeta.Key.contentInsetLeft)
      self.bottom <- map.property(GridableMeta.Key.contentInsetBottom)
      self.right  <- map.property(GridableMeta.Key.contentInsetRight)
    case false:
      self.top    <- map.property(Key.top.rawValue)
      self.left   <- map.property(Key.left.rawValue)
      self.bottom <- map.property(Key.bottom.rawValue)
      self.right  <- map.property(Key.right.rawValue)
    }
  }

  /// Configure struct with a JSON dictionary.
  ///
  /// - Parameter JSON: A JSON dictionary that will be used to configure the content insets.
  public mutating func configure(withJSON JSON: [String : Any]) {
    self.top    <- JSON.property(Key.top.rawValue)
    self.left   <- JSON.property(Key.left.rawValue)
    self.bottom <- JSON.property(Key.bottom.rawValue)
    self.right  <- JSON.property(Key.right.rawValue)
  }

  /// Check if to content insets are equal.
  ///
  /// - parameter lhs: Left hand content inset.
  /// - parameter rhs: Right hand content inset.
  ///
  /// - returns: A boolean value, true if both content insets are equal.
  public static func==(lhs: Inset, rhs: Inset) -> Bool {
    return lhs.top == rhs.top &&
    lhs.left == rhs.left &&
    lhs.bottom == rhs.bottom &&
    lhs.right == rhs.right
  }
}
