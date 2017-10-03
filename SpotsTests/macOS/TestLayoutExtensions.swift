@testable import Spots
import XCTest

class LayoutExtensionsTests: XCTestCase {

  let json: [String : Any] = [
    "item-spacing": 8.0,
    "line-spacing": 6.0,
    "inset": [
      "top": 1.0,
      "left": 2.0,
      "bottom": 3.0,
      "right": 4.0
    ]
  ]

  func testConfigureGridableComponent() {
    let gridComponent = Component(model: ComponentModel(kind: .grid, layout: Layout(span: 1)))
    let componentFlowLayout = gridComponent.collectionView?.flowLayout
    let layout = Layout(json)

    layout.configure(component: gridComponent)

    XCTAssertEqual(componentFlowLayout?.minimumInteritemSpacing, CGFloat(layout.itemSpacing))
    XCTAssertEqual(componentFlowLayout?.minimumLineSpacing, CGFloat(layout.lineSpacing))

    XCTAssertEqual(gridComponent.view.contentInsets.top, CGFloat(layout.inset.top))
    XCTAssertEqual(gridComponent.view.contentInsets.left, CGFloat(layout.inset.left))
    XCTAssertEqual(gridComponent.view.contentInsets.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(gridComponent.view.contentInsets.right, CGFloat(layout.inset.right))
  }

  func testConfigureListableComponent() {
    let listComponent = Component(model: ComponentModel(layout: Layout(span: 1)))
    let layout = Layout(json)

    layout.configure(component: listComponent)

    XCTAssertEqual(listComponent.view.contentInsets.top, CGFloat(layout.inset.top))
    XCTAssertEqual(listComponent.view.contentInsets.left, CGFloat(layout.inset.left))
    XCTAssertEqual(listComponent.view.contentInsets.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(listComponent.view.contentInsets.right, CGFloat(layout.inset.right))
  }
}
