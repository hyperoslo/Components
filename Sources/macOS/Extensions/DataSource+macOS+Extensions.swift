import Cocoa

extension DataSource: NSCollectionViewDataSource {

  public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
    return NSView()
  }

  /// Asks your data source object to provide the number of items in the specified section.
  ///
  /// - parameter collectionView: The collection view requesting the information.
  /// - parameter numberOfItemsInSection: The index number of the section. Section indexes are zero based.
  public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfItems
  }

  /// Asks your data source object to provide the item at the specified location in the collection view.
  ///
  /// - parameter collectionView: The collection view requesting the information
  /// - parameter indexPath: The index path that specifies the location of the item. This index path contains both the section index and the item index within that section.
  ///
  /// - returns: A configured item object. You must not return nil from this method.
  public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    guard let component = component else {
      return NSCollectionViewItem()
    }

    let reuseIdentifier = component.identifier(at: indexPath.item)
    let item = collectionView.makeItem(withIdentifier: reuseIdentifier, for: indexPath)

    switch item {
    case let item as Wrappable:
      viewPreparer.prepareWrappableView(item, atIndex: indexPath.item, in: component, parentFrame: item.bounds)
    case let item as ItemConfigurable:
      item.configure(with: component.model.items[indexPath.item])
    default:
      break
    }

    return item
  }
}

extension DataSource: NSTableViewDataSource {

  /// Returns the number of records managed for aTableView by the data source object.
  ///
  /// - parameter tableView: The table view that sent the message.
  public func numberOfRows(in tableView: NSTableView) -> Int {
    return numberOfItems
  }

  /// Called by aTableView when the mouse button is released over a table view that previously decided to allow a drop.
  ///
  /// - parameter tableView: The table view that sent the message.
  /// - parameter info: An object that contains more information about this dragging operation.
  /// - parameter row: The index of the proposed target row.
  /// - parameter operation: The type of dragging operation.
  ///
  /// - returns: true if the drop operation was successful, otherwise false.
  public func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
    return false
  }
}
