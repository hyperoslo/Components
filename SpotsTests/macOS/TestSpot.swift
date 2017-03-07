@testable import Spots
import XCTest

class TestSpot: XCTestCase {

  override func setUp() {
    Configuration.views.storage = [:]
    Configuration.views.defaultItem = nil
    Configuration.register(view: HeaderView.self, identifier: "Header")
    Configuration.register(view: TextView.self, identifier: "TextView")
    Configuration.register(view: FooterView.self, identifier: "Footer")
  }

  func testDefaultValues() {
    let items = [ContentModel(title: "A"), ContentModel(title: "B")]
    let component = Component(items: items, hybrid: true)
    let spot = Spot(component: component)

    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertNotNil(spot.view)
    XCTAssertNotNil(spot.tableView)
    XCTAssertEqual(spot.items[0].size, CGSize(width: 100, height: 88))
    XCTAssertEqual(spot.items[1].size, CGSize(width: 100, height: 88))
    XCTAssertEqual(spot.view.frame.size, CGSize(width: 100, height: 180))
    let expectedContentSizeHeight: CGFloat = 180
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 100, height: expectedContentSizeHeight))
  }

  func testSpotCache() {
    let item = ContentModel(title: "test")
    let spot = Spot(cacheKey: "test-spot-cache")

    XCTAssertEqual(spot.component.items.count, 0)
    spot.append(item) {
      spot.cache()
    }

    let expectation = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 2.5) {
      guard let cacheKey = spot.stateCache?.key else {
        XCTFail()
        return
      }

      let cachedSpot = Spot(cacheKey: cacheKey)
      XCTAssertEqual(cachedSpot.component.items[0].title, "test")
      XCTAssertEqual(cachedSpot.component.items.count, 1)
      cachedSpot.stateCache?.clear()
      expectation.fulfill()

      cachedSpot.stateCache?.clear()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testHybridListSpotWithHeaderAndFooter() {
    let component = ComponentModel(
      header: "Header",
      footer: "Footer",
      kind: ComponentModel.Kind.list.string,
      items: [
        ContentModel(title: "A"),
        ContentModel(title: "B"),
        ContentModel(title: "C"),
        ContentModel(title: "D")
      ],
      hybrid: true
    )
    let spot = Spot(component: component)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.view.frame.size, CGSize(width: 100, height: 460))
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 100, height: 460))
  }

  func testHybridGridSpotWithHeaderAndFooter() {
    let component = ComponentModel(
      header: "Header",
      footer: "Footer",
      kind: ComponentModel.Kind.grid.string,
      items: [
        ContentModel(title: "A", kind: "TextView"),
        ContentModel(title: "B", kind: "TextView"),
        ContentModel(title: "C", kind: "TextView"),
        ContentModel(title: "D", kind: "TextView")
      ],
      hybrid: true
    )
    let spot = Spot(component: component)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.collectionView?.collectionViewLayout?.collectionViewContentSize, CGSize(width: 100, height: 200))
    XCTAssertEqual(spot.view.frame.size, CGSize(width: 100, height: 300))
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 100, height: 300))
  }

  func testHybridCarouselSpotWithHeaderAndFooter() {
    let component = ComponentModel(
      header: "Header",
      footer: "Footer",
      kind: ComponentModel.Kind.carousel.string,
      items: [
        ContentModel(title: "A", kind: "TextView"),
        ContentModel(title: "B", kind: "TextView"),
        ContentModel(title: "C", kind: "TextView"),
        ContentModel(title: "D", kind: "TextView")
      ],
      hybrid: true
    )
    let spot = Spot(component: component)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.view.frame.size, CGSize(width: 100, height: 150))
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 100, height: 150))
  }
}
