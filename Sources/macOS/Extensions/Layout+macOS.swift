import Cocoa

extension Layout {

  public func configure(component: Component) {
    inset.configure(scrollView: component.view)

    if let layout = component.collectionView?.flowLayout {
      layout.minimumInteritemSpacing = CGFloat(itemSpacing)
      layout.minimumLineSpacing = CGFloat(lineSpacing)
    }
  }

  public func configure(collectionViewLayout: FlowLayout) {
    collectionViewLayout.sectionInset = EdgeInsets(
      top: CGFloat(inset.top),
      left: CGFloat(inset.left),
      bottom: CGFloat(inset.bottom),
      right: CGFloat(inset.right)
    )

    collectionViewLayout.minimumInteritemSpacing = CGFloat(itemSpacing)
    collectionViewLayout.minimumLineSpacing = CGFloat(lineSpacing)
  }
}
