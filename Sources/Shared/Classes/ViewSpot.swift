#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Brick

public class ViewSpot: NSObject, Spotable, Viewable {

  public static var views = Registry()
  public static var configure: ((view: View) -> Void)?
  public static var defaultView: View.Type = View.self
  public static var defaultKind: StringConvertible = "view"

  public weak var spotsCompositeDelegate: SpotsCompositeDelegate?
  public weak var spotsDelegate: SpotsDelegate?
  public var component: Component
  public var index = 0

  public var configure: (SpotConfigurable -> Void)?

  public lazy var scrollView: ScrollView = ScrollView()

  public private(set) var stateCache: SpotCache?

  public var adapter: SpotAdapter?

  /// Indicator to calculate the height based on content
  public var usesDynamicHeight = true

  public required init(component: Component) {
    self.component = component
    super.init()
    registerDefault(view: View.self)
    prepare()
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? ViewSpot.defaultKind.string))
  }

  public func render() -> View {
    return scrollView
  }

  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    return scrollView.frame.size
  }

  public func deselect() {}

  // MARK: - Spotable

  public func register() {}
}
