@testable import Spots
import Brick
import XCTest

class TestSpot: XCTestCase {

  override func setUp() {
    Configuration.views.storage = [:]
    Configuration.views.defaultItem = nil
    Configuration.register(view: HeaderView.self, identifier: "Header")
    Configuration.register(view: TextView.self,   identifier: "TextView")
    Configuration.register(view: FooterView.self, identifier: "Footer")
  }

  func testDefaultValues() {
    let items = [Item(title: "A"), Item(title: "B")]
    let component = Component(items: items, hybrid: true)
    let spot = Spot(component: component)

    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertTrue(spot.userInterface is TableView)
    XCTAssertEqual(spot.items[0].size,    CGSize(width: 100, height: 88))
    XCTAssertEqual(spot.items[1].size,    CGSize(width: 100, height: 88))
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 100, height: 180))
  }

  func testCompareHybridListSpotWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let component = Component(kind: Component.Kind.list.string, items: items, hybrid: true)
    let listComponent = Component(kind: Component.Kind.list.string, items: items)
    let spot = Spot(component: component)
    let listSpot = ListSpot(component: listComponent)

    XCTAssertTrue(type(of: spot.view) == type(of: listSpot.view))

    spot.setup(CGSize(width: 100, height: 100))
    listSpot.setup(CGSize(width: 100, height: 100))
    listSpot.layout(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.items[0].size, listSpot.items[0].size)
    XCTAssertEqual(spot.items[1].size, listSpot.items[0].size)
    XCTAssertEqual(spot.view.frame, listSpot.view.frame)
    XCTAssertEqual(spot.view.contentSize, listSpot.view.contentSize)
  }

  func testCompareHybridGridSpotWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let component = Component(kind: Component.Kind.grid.string, items: items, hybrid: true)
    let gridComponent = Component(kind: Component.Kind.grid.string, items: items)
    let spot = Spot(component: component)
    let gridSpot = GridSpot(component: gridComponent)

    XCTAssertTrue(type(of: spot.view) == type(of: gridSpot.view))

    spot.setup(CGSize(width: 100, height: 100))
    gridSpot.setup(CGSize(width: 100, height: 100))
    gridSpot.view.layoutSubviews()

    XCTAssertEqual(spot.items[0].size, gridSpot.items[0].size)
    XCTAssertEqual(spot.items[1].size, gridSpot.items[0].size)
    XCTAssertEqual(spot.view.frame, gridSpot.view.frame)
    XCTAssertEqual(spot.view.contentSize, gridSpot.view.contentSize)
  }

  func testCompareHybridCarouselSpotWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let component = Component(kind: Component.Kind.carousel.string, items: items, hybrid: true)
    let carouselComponent = Component(kind: Component.Kind.carousel.string, items: items)
    let spot = Spot(component: component)
    let carouselSpot = CarouselSpot(component: carouselComponent)

    XCTAssertTrue(type(of: spot.view) == type(of: carouselSpot.view))

    spot.setup(CGSize(width: 100, height: 100))
    carouselSpot.setup(CGSize(width: 100, height: 100))
    carouselSpot.layout(CGSize(width: 100, height: 100))
    carouselSpot.view.layoutSubviews()

    XCTAssertEqual(spot.items[0].size, carouselSpot.items[0].size)
    XCTAssertEqual(spot.items[1].size, carouselSpot.items[0].size)
    XCTAssertEqual(spot.view.frame, carouselSpot.view.frame)
    XCTAssertEqual(spot.view.contentSize, carouselSpot.view.contentSize)
  }

  func testCompareHybridRowSpotWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let component = Component(kind: Component.Kind.row.string, items: items, hybrid: true)
    let rowComponent = Component(kind: Component.Kind.row.string, items: items)
    let spot = Spot(component: component)
    let rowSpot = RowSpot(component: rowComponent)

    XCTAssertTrue(type(of: spot.view) == type(of: rowSpot.view))

    spot.setup(CGSize(width: 100, height: 100))
    rowSpot.setup(CGSize(width: 100, height: 100))
    rowSpot.view.layoutSubviews()

    XCTAssertEqual(spot.items[0].size, rowSpot.items[0].size)
    XCTAssertEqual(spot.items[1].size, rowSpot.items[0].size)
    XCTAssertEqual(spot.view.frame, rowSpot.view.frame)
    XCTAssertEqual(spot.view.contentSize, rowSpot.view.contentSize)
  }
}
