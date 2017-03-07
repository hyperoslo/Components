/// A generic delegate for Spots
public protocol SpotsDelegate: class {

  /// A delegate method that is triggered when ever a cell is tapped by the user.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter itemSelected: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, itemSelected item: ContentModel)

  /// A delegate method that is triggered when spots is changed.
  ///
  /// - parameter spots: New collection of Spotable objects
  func spotablesDidChange(_ spots: [Spotable])

  /// A delegate method that is triggered when ever a view is going to be displayed.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that will be displayed.
  /// - parameter item: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, willDisplay view: SpotView, item: ContentModel)

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that did end display.
  /// - parameter item: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, didEndDisplaying view: SpotView, item: ContentModel)
}
