#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

open class ViewSpot: NSObject, Spotable, Viewable {

  public var view: View {
    return scrollView
  }

  public static var layout: Layout = .init()

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes: inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation, updateDataSource: () -> Void, completion: Completion) {
    completion?()
  }

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var headers = Registry()
  open static var views = Registry()
  open static var configure: ((_ view: View) -> Void)?
  open static var defaultView: View.Type = View.self
  open static var defaultKind: StringConvertible = "view"

  open weak var delegate: SpotsDelegate?
  open var component: ComponentModel
  open var index = 0
  open var configure: ((ContentConfigurable) -> Void)?

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: SpotsFocusDelegate?

  /// Child spots
  public var compositeSpots: [CompositeSpot] = []

  open lazy var scrollView: ScrollView = ScrollView()

  open fileprivate(set) var stateCache: StateCache?

  public var userInterface: UserInterface?

  public required init(component: ComponentModel) {
    self.component = component

    if self.component.layout == nil {
      self.component.layout = type(of: self).layout
    }

    super.init()
    registerDefault(view: View.self)
    prepare()
  }

  public func ui<T>(at index: Int) -> T? {
    return nil
  }

  /**
   Get the size of the item at the desired index path

   - parameter indexPath: An NSIndexPath

   - returns: The size of the item found using the index path
   */
  open func sizeForItem(at indexPath: IndexPath) -> CGSize {
    return scrollView.frame.size
  }

  /**
   A placeholder method, it is left empty as it holds no value for ViewSpot
   */
  open func deselect() {}

  // MARK: - Spotable

  /**
  A placeholder method, it is left empty as it holds no value for ViewSpot
   */
  open func register() {}

  public func configure(with layout: Layout) {
    /// Do nothing
  }
}
