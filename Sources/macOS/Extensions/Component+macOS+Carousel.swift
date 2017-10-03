import Cocoa

extension Component {
  func setupHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    let newCollectionViewHeight = calculateCollectionViewHeight()

    collectionView.frame.size.height = newCollectionViewHeight
  }

  func layoutHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.flowLayout else {
      return
    }

    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()

    guard let collectionViewContentSize = collectionView.collectionViewLayout?.collectionViewContentSize else {
      return
    }

    let newCollectionViewHeight = calculateCollectionViewHeight()

    collectionView.frame.size.width = collectionViewContentSize.width
    collectionView.frame.size.height = newCollectionViewHeight
    collectionView.frame.size.height += headerHeight + footerHeight

    scrollView.frame.size.width = size.width
    scrollView.contentView.frame.size.width = collectionView.frame.size.width
    scrollView.scrollingEnabled = true
    scrollView.scrollerInsets.bottom = footerHeight
  }

  func resizeHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize, type: ComponentResize) {
    prepareItems()
    layout(with: size, animated: false)
  }

  private func calculateCollectionViewHeight() -> CGFloat {
    var newCollectionViewHeight: CGFloat = model.items.sorted(by: {
      $0.size.height > $1.size.height
    }).first?.size.height ?? 0.0

    newCollectionViewHeight *= CGFloat(model.layout.itemsPerRow)
    newCollectionViewHeight += CGFloat(model.layout.inset.top + model.layout.inset.bottom)

    if model.layout.itemsPerRow > 1 {
      newCollectionViewHeight += CGFloat(model.layout.lineSpacing * Double(model.layout.itemsPerRow - 2))
    }

    return newCollectionViewHeight
  }
}
