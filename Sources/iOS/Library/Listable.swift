#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Sugar
import Brick

/// Listable is a protocol for Spots that are based on TableView
public protocol Listable: Spotable {
  /// The table view object managed by this listable object.
  var tableView: TableView { get }
}

public extension Spotable where Self : Listable {

  /**
   Called when the Listable object is being prepared, it is required by Spotable
   */
  public func prepare() {
    registerAndPrepare { (classType, withIdentifier) in
      tableView.registerClass(classType, forCellReuseIdentifier: withIdentifier)
    }
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter animation: The animation that should be used
   - Parameter completion: Completion
   */
  public func append(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    let count = component.items.count
    component.items.append(item)

    dispatch { [weak self] in
      self?.tableView.insert([count], animation: animation.tableViewAnimation)
      completion?()
    }
    var cached: RegularView?
    prepareItem(item, index: count, cached: &cached)
  }

  /**
   - Parameter item: A collection of view models that you want to insert
   - Parameter animation: The animation that should be used
   - Parameter completion: Completion
   */
  public func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let count = component.items.count

    component.items.appendContentsOf(items)

    var cached: RegularView?
    items.enumerate().forEach {
      indexes.append(count + $0.index)
      prepareItem($0.element, index: count + $0.index, cached: &cached)
    }

    dispatch { [weak self] in
      self?.tableView.insert(indexes, animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index where the new ViewModel should be inserted
   - Parameter animation: The animation that should be used
   - Parameter completion: Completion
   */
  public func insert(item: ViewModel, index: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    component.items.insert(item, atIndex: index)

    dispatch { [weak self] in
      self?.tableView.insert([index], animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: A collection of view model that you want to prepend
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()

    component.items.insertContentsOf(items, at: 0)

    items.enumerate().forEach {
      indexes.append(items.count - 1 - $0.index)
    }

    dispatch { [weak self] in
      self?.tableView.insert(indexes, animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: The view model that you want to remove
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    guard let index = component.items.indexOf({ $0 == item })
      else { completion?(); return }

    component.items.removeAtIndex(index)

    dispatch { [weak self] in
      self?.tableView.delete([index], animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: A collection of view models that you want to delete
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    var indexPaths = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      indexPaths.append(count + index)
      component.items.append(item)
    }

    dispatch { [weak self] in
      self?.tableView.delete(indexPaths, animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    dispatch { [weak self] in
      self?.component.items.removeAtIndex(index)
      self?.tableView.delete([index], animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter indexes: An array of indexes that you want to remove
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    dispatch { [weak self] in
      indexes.forEach { self?.component.items.removeAtIndex($0) }
      self?.tableView.delete(indexes, section: 0, animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: The new update view model that you want to update at an index
   - Parameter index: The index of the view model, defaults to 0
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been updated
   */
  public func update(item: ViewModel, index: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    items[index] = item

    let reuseIdentifier = reuseIdentifierForItem(NSIndexPath(forRow: index, inSection: 0))
    let cellClass = self.dynamicType.views.storage[reuseIdentifier] ?? self.dynamicType.defaultView

    tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)

    if let cell = cellClass.init() as? SpotConfigurable {
      component.items[index].index = index
      cell.configure(&component.items[index])
    }

    tableView.reload([index], section: 0, animation: animation.tableViewAnimation)
    completion?()
  }

  /**
   - Parameter indexes: An array of integers that you want to reload, default is nil
   - Parameter animated: Perform reload animation
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded
   */
  public func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    refreshIndexes()

    for (index, _) in component.items.enumerate() {
      let reuseIdentifier = reuseIdentifierForItem(NSIndexPath(forItem: index, inSection: 0))
      let cellClass = self.dynamicType.views.storage[reuseIdentifier] ?? self.dynamicType.defaultView

      tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)

      if let cell = cellClass.init() as? SpotConfigurable {
        component.items[index].index = index
        cell.configure(&component.items[index])
      }
    }

    animation != .None ? tableView.reloadSection(0, animation: animation.tableViewAnimation) : tableView.reloadData()
    tableView.setNeedsLayout()
    tableView.layoutIfNeeded()
    RegularView.setAnimationsEnabled(true)
    completion?()
  }

  /**
   - Returns: ScrollView: Returns a TableView as a ScrollView
   */
  public func render() -> ScrollView {
    return tableView
  }

  /**
   - Parameter size: A CGSize to set the width of the table view
   */
  public func layout(size: CGSize) {
    tableView.width = size.width
    tableView.layoutIfNeeded()
  }

  /**
   - Parameter includeElement: A filter predicate to find a view model
   - Returns: A calculate CGFloat based on what the includeElement matches
   */
  public func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat {
    guard let item = items.filter(includeElement).first else { return 0.0 }

    return component.items[0...item.index]
      .reduce(0, combine: { $0 + $1.size.height })
  }
}
