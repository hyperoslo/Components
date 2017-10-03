#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

/// A type alias for a anonymous completion
public typealias Completion = (() -> Void)?

#if os(OSX)
  /// A type alias to reference a normal platform view
  public typealias View = NSView
  /// A type alias to reference a custom scroll view
  public typealias ScrollView = ComponentScrollView
  /// A type alias to reference a table view
  public typealias TableView = NSTableView
  /// A type alias to reference a collection view
  public typealias CollectionView = NSCollectionView
  /// A type alias to reference a nib file
  public typealias Nib = NSNib
  /// A type alias to reference a collection layout
  public typealias CollectionLayout = NSCollectionViewLayout
  /// A type alias to reference a collection flow layout
  public typealias FlowLayout = NSCollectionViewFlowLayout
  /// A type alias for scrollable views
  public typealias ScrollableView = SpotsScrollView
#else
  /// A type alias to reference a view passed to delegate method
  public typealias ComponentView = UIView
  /// A type alias to reference a normal platform view
  public typealias View = UIView
  /// A type alias to reference a normal scroll view
  public typealias ScrollView = UIScrollView
  /// A type alias to reference a table view
  public typealias TableView = UITableView
  /// A type alias to reference a collection view
  public typealias CollectionView = UICollectionView
  /// A type alias to reference a nib file
  public typealias Nib = UINib
  /// A type alias to reference a collection layout
  public typealias CollectionLayout = ComponentFlowLayout
  /// A type alias to reference a collection flow layout
  public typealias FlowLayout = UICollectionViewFlowLayout
  /// A type alias to reference a edge insets
  public typealias EdgeInsets = UIEdgeInsets
  /// A type alias for scrollable views
  public typealias ScrollableView = UIScrollView
#endif
