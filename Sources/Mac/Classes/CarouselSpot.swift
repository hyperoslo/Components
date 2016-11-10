import Cocoa
import Brick

open class CarouselSpot: NSObject, Gridable {

  public struct Key {
    public static let minimumInteritemSpacing = "item-spacing"
    public static let minimumLineSpacing = "line-spacing"
    public static let titleFontSize = "title-font-size"
    public static let titleLeftMargin = "title-left-margin"
    public static let titleTopInset = "title-top-inset"
    public static let titleBottomInset = "title-bottom-inset"
    public static let titleLeftInset = "title-left-inset"
    public static let titleTextColor = "title-text-color"
  }

  public struct Default {
    public static var titleFontSize: CGFloat = 18.0
    public static var titleLeftInset: CGFloat = 0.0
    public static var titleTopInset: CGFloat = 10.0
    public static var titleBottomInset: CGFloat = 10.0
    public static var titleTextColor: String = "000000"
    /// Default section inset top
    public static var sectionInsetTop: CGFloat = 0.0
    /// Default section inset left
    public static var sectionInsetLeft: CGFloat = 0.0
    /// Default section inset right
    public static var sectionInsetRight: CGFloat = 0.0
    /// Default section inset bottom
    public static var sectionInsetBottom: CGFloat = 0.0
    /// Default default minimum interitem spacing
    public static var minimumInteritemSpacing: CGFloat = 0.0
    /// Default minimum line spacing
    public static var minimumLineSpacing: CGFloat = 0.0
  }

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var views = Registry()

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var grids = GridRegistry()

  open static var configure: ((_ view: NSCollectionView) -> Void)?

  open static var defaultGrid: NSCollectionViewItem.Type = NSCollectionViewItem.self

  open static var defaultView: View.Type = NSView.self

  open static var defaultKind: StringConvertible = Component.Kind.Carousel.string

  /// A SpotsDelegate that is used for the CarouselSpot
  open weak var delegate: SpotsDelegate?

  open var component: Component
  open var configure: ((SpotConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      for case let cell as SpotConfigurable in collectionView.visibleItems() {
        configure(cell)
      }
    }
  }

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  open fileprivate(set) var stateCache: StateCache?

  open var gradientLayer: CAGradientLayer?

  open lazy var layout: NSCollectionViewLayout = NSCollectionViewFlowLayout()

  open lazy var titleView: NSTextField = {
    let titleView = NSTextField()
    titleView.isEditable = false
    titleView.isSelectable = false
    titleView.isBezeled = false
    titleView.drawsBackground = false
    titleView.textColor = NSColor.gray

    return titleView
  }()

  open lazy var scrollView: ScrollView = ScrollView()
  open var collectionView: CollectionView

  /// Operation queue for spot mutations
  public var operationQueue: OperationQueue

  lazy var lineView: NSView = {
    let lineView = NSView()
    lineView.frame.size.height = 1
    lineView.wantsLayer = true
    lineView.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor

    return lineView
  }()

  var spotDataSource: DataSource?
  var spotDelegate: Delegate?

  /// A required initializer to instantiate a CarouselSpot with a component.
  ///
  /// - parameter component: A component
  ///
  /// - returns: An initialized carousel spot.
  public required init(component: Component) {
    self.component = component
    self.collectionView = CollectionView()
    operationQueue = OperationQueueBuilder.build()
    super.init()
    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    if component.kind.isEmpty {
      self.component.kind = Component.Kind.Carousel.string
    }

    registerAndPrepare()
    setupCollectionView()
    configureLayoutInsets(component)

    if let layout = layout as? NSCollectionViewFlowLayout, !component.title.isEmpty {
      configureTitleView(layout.sectionInset)
    }
    scrollView.addSubview(titleView)
    scrollView.addSubview(lineView)
    scrollView.documentView = collectionView
  }

  /// Instantiate a CarouselSpot with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the Spotable object.
  ///
  /// - returns: An initialized carousel spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    registerAndPrepare()
  }

  deinit {
    operationQueue.cancelAllOperations()
    collectionView.delegate = nil
    collectionView.dataSource = nil
    spotDataSource = nil
    spotDelegate = nil
  }

  fileprivate func configureLayoutInsets(_ component: Component) {
    guard let layout = layout as? NSCollectionViewFlowLayout else { return }

    layout.sectionInset = EdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))
    layout.minimumInteritemSpacing = component.meta(Key.minimumInteritemSpacing, Default.minimumInteritemSpacing)
    layout.minimumLineSpacing = component.meta(Key.minimumLineSpacing, Default.minimumLineSpacing)
    layout.scrollDirection = .horizontal
  }

  /// Configure collection view delegate, data source and layout
  open func setupCollectionView() {
    collectionView.isSelectable = true
    collectionView.backgroundColors = [NSColor.clear]

    let view = NSView()
    collectionView.backgroundView = view
    collectionView.dataSource = spotDataSource
    collectionView.delegate = spotDelegate
    collectionView.collectionViewLayout = layout
  }

  open func render() -> ScrollView {
    return scrollView
  }

  open func layout(_ size: CGSize) {
    var layoutInsets = EdgeInsets()

    if let layout = layout as? NSCollectionViewFlowLayout {
      layout.sectionInset.top = component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop) + titleView.frame.size.height + 8
      layoutInsets = layout.sectionInset
    }

    scrollView.frame.size.height = (component.items.first?.size.height ?? layoutInsets.top) + layoutInsets.top + layoutInsets.bottom
    collectionView.frame.size.height = scrollView.frame.size.height
    gradientLayer?.frame.size.height = scrollView.frame.size.height

    if !component.title.isEmpty {
      configureTitleView(layoutInsets)
    }

    if component.span > 0 {
      component.items.enumerated().forEach {
        component.items[$0.offset].size.width = size.width / CGFloat(component.span)
      }
    }

    if component.span == 1 && component.items.count == 1 {
      scrollView.scrollingEnabled = (component.items.count > 1)
      scrollView.hasHorizontalScroller = (component.items.count > 1)
      component.items.enumerated().forEach {
        component.items[$0.offset].size.width = size.width / CGFloat(component.span)
      }
      layout.invalidateLayout()
    }
  }

  /// Setup Spotable component with base size
  ///
  /// - parameter size: The size of the superview
  open func setup(_ size: CGSize) {
    if component.span > 0 {
      component.items.enumerated().forEach {
        component.items[$0.offset].size.width = size.width / CGFloat(component.span)
      }
    }

    layout(size)
    CarouselSpot.configure?(collectionView)
  }

  fileprivate func configureTitleView(_ layoutInsets: EdgeInsets) {
    titleView.stringValue = component.title
    titleView.sizeToFit()
    titleView.font = NSFont.systemFont(ofSize: component.meta(Key.titleFontSize, Default.titleFontSize))
    titleView.sizeToFit()
    titleView.frame.size.width = collectionView.frame.width - layoutInsets.right - layoutInsets.left
    lineView.frame.size.width = scrollView.frame.size.width - (component.meta(Key.titleLeftMargin, titleView.frame.origin.x) * 2)
    lineView.frame.origin.x = component.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.x = collectionView.frame.origin.x + component.meta(Key.titleLeftInset, Default.titleLeftInset)
    titleView.frame.origin.x = component.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.y = component.meta(Key.titleTopInset, Default.titleTopInset) - component.meta(Key.titleBottomInset, Default.titleBottomInset)
    lineView.frame.origin.y = titleView.frame.maxY + 5
    collectionView.frame.size.height = scrollView.frame.size.height + titleView.frame.size.height
  }

  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    var width = component.span > 0
      ? collectionView.frame.width / CGFloat(component.span)
      : collectionView.frame.width

    if let layout = layout as? NSCollectionViewFlowLayout {
      width -= layout.sectionInset.left - layout.sectionInset.right
      width -= layout.minimumInteritemSpacing
      width -= layout.minimumLineSpacing
    }

    if component.items[indexPath.item].size.width == 0.0 {
      component.items[indexPath.item].size.width = width
    }

    return CGSize(
      width: ceil(component.items[indexPath.item].size.width),
      height: ceil(component.items[indexPath.item].size.height))
  }
}
