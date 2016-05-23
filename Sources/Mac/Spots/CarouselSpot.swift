import Cocoa
import Sugar
import Brick

@available(OSX 10.11, *)
public class CarouselLayout: NSCollectionViewFlowLayout {
}

public class CarouselSpot: NSObject, Gridable {

  public static var views = ViewRegistry()
  public static var grids = GridRegistry()
  public static var configure: ((view: NSCollectionView) -> Void)?
  public static var defaultView: RegularView.Type = NSView.self
  public static var defaultKind: StringConvertible = "carousel"
  
  public weak var spotsDelegate: SpotsDelegate?
  
  public var cachedViews = [String : SpotConfigurable]()
  public var component: Component
  public var configure: (SpotConfigurable -> Void)?
  public var index = 0
  
  public private(set) var stateCache: SpotCache?
  
  public lazy var adapter: CollectionAdapter = CollectionAdapter(spot: self)
  @available(OSX 10.11, *)
  public lazy var layout: NSCollectionViewLayout = NSCollectionViewFlowLayout().then {
    if #available(OSX 10.11, *) {
      $0.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      $0.minimumInteritemSpacing = 0
      $0.minimumLineSpacing = 0
      $0.scrollDirection = .Horizontal
    }
  }
  
  public lazy var scrollView: ScrollView = ScrollView().then {
    $0.documentView = NSView()
    $0.autoresizingMask = .ViewWidthSizable
  }
  
  public lazy var collectionView: NSCollectionView = NSCollectionView().then {
    $0.autoresizingMask = .ViewWidthSizable
    $0.backgroundColors = [NSColor.clearColor()]
  }
  
  public required init(component: Component) {
    self.component = component
    super.init()
    
    setupCollectionView()
    scrollView.contentView.addSubview(collectionView)
  }
  
  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? GridSpot.defaultKind.string))
  }
  
  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)
    
    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
    
    //prepare()
  }
  
  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)
    
    if #available(OSX 10.11, *) {
      guard let layout = layout as? NSCollectionViewFlowLayout else { return }
      layout.sectionInset = NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
      layout.minimumInteritemSpacing = itemSpacing
      layout.minimumLineSpacing = lineSpacing
      layout.scrollDirection = .Horizontal
    }
  }
  
  public func setupCollectionView() {
    //    collectionView.maxNumberOfColumns = Int(component.span)
    if #available(OSX 10.11, *) {
      collectionView.delegate = adapter
      collectionView.dataSource = adapter
      collectionView.collectionViewLayout = layout
    }
  }
  
  public func render() -> RegularView {
    return scrollView
  }
  
  public func setup(size: CGSize) {
    if component.span > 0 {
      component.items.enumerate().forEach {
        component.items[$0.index].size.width = size.width
      }
    }
    
    scrollView.frame.size = size
    collectionView.frame.size = size
    
    CarouselSpot.configure?(view: collectionView)
  }
  
  public func append(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func append(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func delete(item: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func delete(index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func delete(indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func reload(indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion) {}
}

extension CarouselSpot {
  
  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    var width = component.span > 0
      ? collectionView.frame.width / CGFloat(component.span)
      : collectionView.frame.width

    if #available(OSX 10.11, *) {
      if let layout = layout as? NSCollectionViewFlowLayout {
        width -= layout.sectionInset.left - layout.sectionInset.right
        width -= layout.minimumInteritemSpacing
        width -= layout.minimumLineSpacing
      }
      
      component.items[indexPath.item].size.width = width
    
      return CGSize(
        width: ceil(component.items[indexPath.item].size.width),
        height: ceil(component.items[indexPath.item].size.height))
    } else {
      return CGSize.zero
    }
  }
}