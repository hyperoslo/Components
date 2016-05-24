import UIKit
import Sugar
import Brick
import Cache

/**
 SpotsController is a subclass of UIViewController
 */
public class SpotsController: UIViewController, UIScrollViewDelegate {

  /// A static closure to configure SpotsScrollView
  public static var configure: ((container: SpotsScrollView) -> Void)?

  /// Initial content offset for SpotsController, defaults to UIEdgeInsetsZero
  public private(set) var initialContentInset: UIEdgeInsets = UIEdgeInsetsZero
  /// A collection of Spotable objects
  public private(set) var spots: [Spotable] {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling
  public var refreshPositions = [CGFloat]()
  /// A bool value to indicate if the SpotsController is refeshing
  public var refreshing = false

  public var dictionary: JSONDictionary {
    get {
      return ["components" : spots.map { $0.component.dictionary }]
    }
  }

  var stateCache: SpotCache?

  /// A delegate for when an item is tapped within a Spot
  weak public var spotsDelegate: SpotsDelegate? {
    didSet {
      spots.forEach { $0.spotsDelegate = spotsDelegate }
      spotsDelegate?.spotsDidChange(spots)
    }
  }

  /// A convenience method for resolving the first spot
  public var spot: Spotable? {
    get { return spot(0, Spotable.self) }
  }

#if os(iOS)
  /// A refresh delegate for handling reloading of a Spot
  weak public var spotsRefreshDelegate: SpotsRefreshDelegate? {
    didSet {
      refreshControl.hidden = spotsRefreshDelegate == nil
    }
  }
#endif

  /// A scroll delegate for handling spotDidReachBeginning and spotDidReachEnd
  weak public var spotsScrollDelegate: SpotsScrollDelegate?

  /// A custom scroll view that handles the scrolling for all internal scroll views
  lazy public var spotsScrollView: SpotsScrollView = SpotsScrollView().then { [weak self] in
    guard let strongSelf = self else { return }

    $0.frame = strongSelf.view.frame
    $0.alwaysBounceVertical = true
    $0.clipsToBounds = true
    $0.delegate = strongSelf
  }

#if os(iOS)
  /// A UIRefresh control
  /// Note: Only avaiable on iOS
  public lazy var refreshControl: UIRefreshControl = { [unowned self] in
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshSpots(_:)), forControlEvents: .ValueChanged)

    return refreshControl
  }()
#endif

  // MARK: Initializer

  /**
   - Parameter spots: An array of Spotable objects
   */
  public required init(spots: [Spotable] = []) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)
  }

  /**
   - Parameter spot: A Spotable object
   */
  public convenience init(spot: Spotable)  {
    self.init(spots: [spot])
  }

  /**
   - Parameter json: A JSON dictionary that gets parsed into UI elements
   */
  public convenience init(_ json: [String : AnyObject]) {
    self.init(spots: Parser.parse(json))
  }

  /**
   - Parameter cacheKey: A key that will be used to identify the SpotCache
   */
  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)
    self.init(spots: Parser.parse(stateCache.load()))
    self.stateCache = stateCache
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life Cycle

  /// Called after the spot controller's view is loaded into memory.
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(spotsScrollView)

    setupSpots()

    SpotsController.configure?(container: spotsScrollView)
  }

  /// Notifies the spot controller that its view is about to be added to a view hierarchy.
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    spotsScrollView.forceUpdate = true

    if let tabBarController = self.tabBarController
      where tabBarController.tabBar.translucent {
        spotsScrollView.contentInset.bottom = tabBarController.tabBar.height
        spotsScrollView.scrollIndicatorInsets.bottom = spotsScrollView.contentInset.bottom
    }
#if os(iOS)
    guard let _ = spotsRefreshDelegate else { return }

    spotsScrollView.insertSubview(refreshControl, atIndex: 0)
#endif
  }

  /// Notifies the container that the size of tis view is about to change.
  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
  }

  /**
   - Parameter animated: An optional animation closure that runs when a spot is being rendered
  */
  public func setupSpots(animated: ((view: UIView) -> Void)? = nil) {
    spots.enumerate().forEach { index, spot in
      spots[index].index = index
      spot.render().optimize()
      spotsScrollView.contentView.addSubview(spot.render())
      spot.prepare()
      spot.setup(spotsScrollView.frame.size)
      spot.component.size = CGSize(
        width: view.width,
        height: ceil(spot.render().height))
      animated?(view: spot.render())
    }
  }

  /**
   Clear Spots cache
   */
  public static func clearCache() {
    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
                                                    NSSearchPathDomainMask.UserDomainMask, true)
    let path = "\(paths.first!)/\(DiskStorage.prefix).\(SpotCache.cacheName)"
    do { try NSFileManager.defaultManager().removeItemAtPath(path) }
    catch { NSLog("Could not remove cache at path: \(path)") }
  }
}

// MARK: - Public SpotController methods

extension SpotsController {

  /**
   A generic look up method for resolving spots based on index

   - Parameter index: The index of the spot that you are trying to resolve
   - Parameter type: The generic type for the spot you are trying to resolve
   */
  public func spot<T>(index: Int = 0, _ type: T.Type) -> T? {
    return spots.filter({ $0.index == index }).first as? T
  }

  /**
   A generic look up method for resolving spots using a closure

   - Parameter closure: A closure to perform actions on a spotable object
   */
  public func spot(@noescape closure: (index: Int, spot: Spotable) -> Bool) -> Spotable? {
    for (index, spot) in spots.enumerate()
      where closure(index: index, spot: spot) {
        return spot
    }
    return nil
  }

  /**
   - Parameter includeElement: A filter predicate to find a spot
   */
  public func filter(@noescape includeElement: (Spotable) -> Bool) -> [Spotable] {
    return spots.filter(includeElement)
  }

  /**
   - Parameter completion: A closure that will be run after reload has been performed on all spots
   */
  public func reload(animated: Bool = true, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    var spotsLeft = spots.count

    dispatch { [weak self] in
      self?.spots.forEach { spot in
        spot.reload([], withAnimation: animation) {
          spotsLeft -= 1

          if spotsLeft == 0 {
            completion?()
          }
        }
      }
    }
  }

  /**
   - Parameter json: A JSON dictionary that gets parsed into UI elements
   - Parameter completion: A closure that will be run after reload has been performed on all spots
  */
  public func reloadIfNeeded(json: [String : AnyObject], animated: ((view: UIView) -> Void)? = nil, closure: Completion = nil) {
    let newSpots = Parser.parse(json)
    let newComponents = newSpots.map { $0.component }
    let oldComponents = spots.map { $0.component }

    guard oldComponents != newComponents else {
      cache()
      closure?()
      return
    }

    spots = newSpots
    cache()

    if spotsScrollView.superview == nil {
      view.addSubview(spotsScrollView)
    }

    spotsScrollView.contentView.subviews.forEach { $0.removeFromSuperview() }
    setupSpots(animated)
    spotsScrollView.forceUpdate = true

    closure?()
  }

  /**
   - Parameter json: A JSON dictionary that gets parsed into UI elements
   - Parameter completion: A closure that will be run after reload has been performed on all spots
  */
  public func reload(json: [String : AnyObject], animated: ((view: UIView) -> Void)? = nil, closure: Completion = nil) {
    spots = Parser.parse(json)
    cache()

    if spotsScrollView.superview == nil {
      view.addSubview(spotsScrollView)
    }

    spotsScrollView.contentView.subviews.forEach { $0.removeFromSuperview() }
    setupSpots(animated)
    spotsScrollView.forceUpdate = true

    closure?()
  }

  /**
   - Parameter spotAtIndex: The index of the spot that you want to perform updates on
   - Parameter animated: Perform reload animation
   - Parameter closure: A transform closure to perform the proper modification to the target spot before updating the internals
   */
  public func update(spotAtIndex index: Int = 0, withAnimation animation: SpotsAnimation = .Automatic, withCompletion completion: Completion = nil, @noescape _ closure: (spot: Spotable) -> Void) {
    guard let spot = spot(index, Spotable.self) else { completion?(); return }
    closure(spot: spot)
    spot.refreshIndexes()
    spot.prepare()

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.spot(spot.index, Spotable.self)?.reload([index], withAnimation: animation) {
        weakSelf.spotsScrollView.setNeedsDisplay()
        weakSelf.spotsScrollView.forceUpdate = true
        completion?()
      }
    }
  }

  /**
   Updates spot only if the passed view models are not the same with the current ones.
   - Parameter spotAtIndex: The index of the spot that you want to perform updates on
   - Parameter items: An array of view models
   */
  public func updateIfNeeded(spotAtIndex index: Int = 0, items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    guard let spot = spot(index, Spotable.self) where !(spot.items == items) else {
      completion?()
      return
    }

    update(spotAtIndex: index, withAnimation: animation, withCompletion: completion, {
      $0.items = items
    })
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func append(item: ViewModel, spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.append(item, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter items: A collection of view models
   - Parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func append(items: [ViewModel], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.append(items, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter items: A collection of view models
   - Parameter spotIndex: The index of the spot that you want to prepend to, defaults to 0
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func prepend(items: [ViewModel], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.prepend(items, withAnimation: animation)  {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index that you want to insert the view model at
   - Parameter spotIndex: The index of the spot that you want to insert into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func insert(item: ViewModel, index: Int = 0, spotIndex: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.insert(item, index: index, withAnimation: animation)  {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter item: The view model that you want to update
   - Parameter index: The index that you want to insert the view model at
   - Parameter spotIndex: The index of the spot that you want to update into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func update(item: ViewModel, index: Int = 0, spotIndex: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let oldItem = spot(spotIndex, Spotable.self)?.item(index) where item != oldItem
      else {
        spot(spotIndex, Spotable.self)?.refreshIndexes()
        completion?()
        return
    }

    spot(spotIndex, Spotable.self)?.update(item, index: index, withAnimation: animation)  {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter indexes: An integer array of indexes that you want to update
   - Parameter spotIndex: The index of the spot that you want to update into
   - Parameter animated: Perform reload animation
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func update(indexes indexes: [Int], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.reload(indexes, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter spotIndex: The index of the spot that you want to remove into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(index: Int, spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.delete(index, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter indexes: A collection of indexes for view models that you want to remove
   - Parameter spotIndex: The index of the spot that you want to remove into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(indexes indexes: [Int], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.delete(indexes, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

#if os(iOS)
  public func refreshSpots(refreshControl: UIRefreshControl) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.refreshPositions.removeAll()
      weakSelf.spotsRefreshDelegate?.spotsDidReload(refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }
#endif

  /**
   - Parameter index: The index of the spot that you want to scroll
   - Parameter includeElement: A filter predicate to find a view model
   */
  public func scrollTo(spotIndex index: Int = 0, @noescape includeElement: (ViewModel) -> Bool) {
    guard let itemY = spot(index, Spotable.self)?.scrollTo(includeElement) else { return }

    var initialHeight: CGFloat = 0.0
    if index > 0 {
      initialHeight += spots[0..<index].reduce(0, combine: { $0 + $1.spotHeight() })
    }

    if spot(index, Spotable.self)?.spotHeight() > spotsScrollView.height - spotsScrollView.contentInset.bottom - initialHeight {
      let y = itemY - spotsScrollView.height + spotsScrollView.contentInset.bottom + initialHeight
      spotsScrollView.setContentOffset(CGPoint(x: CGFloat(0.0), y: y), animated: true)
    }
  }

  /**
   - Parameter animated: A boolean value to determine if you want to perform the scrolling with or without animation
   */
  public func scrollToBottom(animated: Bool) {
    let y = spotsScrollView.contentSize.height - spotsScrollView.height + spotsScrollView.contentInset.bottom
    spotsScrollView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
  }

  /**
   Caches the current state of the spot controller
   */
  public func cache() {
    stateCache?.save(dictionary)
  }
}

// MARK: - Private methods

/// An extension with private methods on SpotsController
extension SpotsController {

  /**
   - Parameter indexPath: The index path of the component you want to lookup
   */
  private func component(indexPath: NSIndexPath) -> Component {
    return spot(indexPath).component
  }

  /**
   - Parameter indexPath: The index path of the spot you want to lookup
   */
  private func spot(indexPath: NSIndexPath) -> Spotable {
    return spots[indexPath.item]
  }
}
