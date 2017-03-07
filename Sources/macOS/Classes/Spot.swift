// swiftlint:disable weak_delegate

import Cocoa
import Tailor

public class Spot: NSObject, Spotable {

  public static var layout: Layout = Layout(span: 1.0)
  public static var headers: Registry = Registry()
  public static var views: Registry = Registry()
  public static var defaultKind: String = ComponentModel.Kind.list.string

  open static var configure: ((_ view: View) -> Void)?

  weak public var focusDelegate: SpotsFocusDelegate?
  weak public var delegate: SpotsDelegate?

  var headerView: View?
  var footerView: View?

  public var component: ComponentModel
  public var componentKind: ComponentModel.Kind = .list
  public var compositeSpots: [CompositeSpot] = []
  public var configure: ((ContentConfigurable) -> Void)?
  public var spotDelegate: Delegate?
  public var spotDataSource: DataSource?
  public var stateCache: StateCache?
  public var userInterface: UserInterface?
  open var gradientLayer: CAGradientLayer?

  public var responder: NSResponder {
    switch self.userInterface {
    case let tableView as TableView:
      return tableView
    case let collectionView as CollectionView:
      return collectionView
    default:
      return scrollView
    }
  }

  public var nextResponder: NSResponder? {
    get {
      switch self.userInterface {
      case let tableView as TableView:
        return tableView.nextResponder
      case let collectionView as CollectionView:
        return collectionView.nextResponder
      default:
        return scrollView.nextResponder
      }
    }
    set {
      switch self.userInterface {
      case let tableView as TableView:
        tableView.nextResponder = newValue
      case let collectionView as CollectionView:
        collectionView.nextResponder = newValue
      default:
        scrollView.nextResponder = newValue
      }
    }
  }

  public func deselect() {
    switch self.userInterface {
    case let tableView as TableView:
      tableView.deselectAll(nil)
    case let collectionView as CollectionView:
      collectionView.deselectAll(nil)
    default: break
    }
  }

  open lazy var scrollView: ScrollView = ScrollView(documentView: self.documentView)
  open lazy var documentView: FlippedView = FlippedView()

  var headerHeight: CGFloat {
    guard let headerView = headerView else {
      return 0.0
    }

    return headerView.frame.size.height
  }

  var footerHeight: CGFloat {
    guard let footerView = footerView else {
      return 0.0
    }

    return footerView.frame.size.height
  }

  public var view: ScrollView {
    return scrollView
  }

  public var tableView: TableView? {
    return userInterface as? TableView
  }

  public var collectionView: CollectionView? {
    return userInterface as? CollectionView
  }

  public required init(component: ComponentModel, userInterface: UserInterface, kind: ComponentModel.Kind) {
    self.component = component
    self.componentKind = kind
    self.userInterface = userInterface

    super.init()

    if component.layout == nil {
      switch kind {
      case .carousel:
        self.component.layout = CarouselSpot.layout
      case .grid:
        self.component.layout = GridSpot.layout
      case .list:
        self.component.layout = ListSpot.layout
        registerDefaultIfNeeded(view: ListSpotItem.self)
      case .row:
        self.component.layout = RowSpot.layout
      default:
        break
      }
    }

    userInterface.register()

    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)
  }

  public required convenience init(component: ComponentModel) {
    var component = component
    if component.kind.isEmpty {
      component.kind = Spot.defaultKind
    }

    let kind = ComponentModel.Kind(rawValue: component.kind) ?? .list
    let userInterface: UserInterface

    if kind == .list {
      userInterface = TableView()
    } else {
      let collectionView = CollectionView(frame: CGRect.zero)
      collectionView.collectionViewLayout = GridableLayout()
      userInterface = collectionView
    }

    self.init(component: component, userInterface: userInterface, kind: kind)

    if componentKind == .carousel {
      self.component.interaction.scrollDirection = .horizontal
      (collectionView?.collectionViewLayout as? FlowLayout)?.scrollDirection = .horizontal
    }
  }

  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(component: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  public func configure(with layout: Layout) {

  }

  fileprivate func configureDataSourceAndDelegate() {
    if let tableView = self.tableView {
      tableView.dataSource = spotDataSource
      tableView.delegate = spotDelegate
    } else if let collectionView = self.collectionView {
      collectionView.dataSource = spotDataSource
      collectionView.delegate = spotDelegate
    }
  }

  public func setup(_ size: CGSize) {
    type(of: self).configure?(view)

    scrollView.frame.size = size

    setupHeader(kind: component.header)
    setupFooter(kind: component.footer)

    if let tableView = self.tableView {
      documentView.addSubview(tableView)
      setupTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      documentView.addSubview(collectionView)
      setupCollectionView(collectionView, with: size)
    }

    layout(size)
  }

  public func layout(_ size: CGSize) {
    if let tableView = self.tableView {
      layoutTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      layoutCollectionView(collectionView, with: size)
    }

    layoutHeaderFooterViews(size)

    view.layoutSubviews()
  }

  fileprivate func setupCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if let componentLayout = self.component.layout,
      let collectionViewLayout = collectionView.collectionViewLayout as? FlowLayout {
      componentLayout.configure(collectionViewLayout: collectionViewLayout)
    }

    collectionView.frame.size = size

    prepareItems()

    collectionView.backgroundColors = [NSColor.clear]
    collectionView.isSelectable = true
    collectionView.allowsMultipleSelection = false
    collectionView.allowsEmptySelection = true
    collectionView.layer = CALayer()
    collectionView.wantsLayer = true
    collectionView.dataSource = spotDataSource
    collectionView.delegate = spotDelegate

    let backgroundView = NSView()
    backgroundView.wantsLayer = true
    collectionView.backgroundView = backgroundView

    switch componentKind {
    case .carousel:
      setupHorizontalCollectionView(collectionView, with: size)
    default:
      setupVerticalCollectionView(collectionView, with: size)
    }
  }

  fileprivate func layoutCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if componentKind == .carousel {
      layoutHorizontalCollectionView(collectionView, with: size)
    } else {
      layoutVerticalCollectionView(collectionView, with: size)
    }
  }

  func registerDefaultIfNeeded(view: View.Type) {
    guard Configuration.views.storage[Configuration.views.defaultIdentifier] == nil else {
      return
    }

    Configuration.views.defaultItem = Registry.Item.classType(view)
  }

  open func doubleAction(_ sender: Any?) {
    guard let tableView = tableView,
      let item = item(at: tableView.clickedRow) else {
      return
    }
    delegate?.spotable(self, itemSelected: item)
  }

  open func action(_ sender: Any?) {
    guard let tableView = tableView,
      let item = item(at: tableView.clickedRow) else {
        return
    }
    delegate?.spotable(self, itemSelected: item)
  }

  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    if let collectionView = collectionView,
      component.interaction.scrollDirection == .horizontal {
      var width: CGFloat

      if let layout = component.layout {
        width = layout.span > 0
          ? collectionView.frame.width / CGFloat(layout.span)
          : collectionView.frame.width
      } else {
        width = collectionView.frame.width
      }

      if let layout = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout {
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
    } else {
      return CGSize(
        width:  item(at: indexPath)?.size.width  ?? 0.0,
        height: item(at: indexPath)?.size.height ?? 0.0
      )
    }
  }

  public func register() {

  }
}
