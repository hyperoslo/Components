@testable import Spots
import Foundation
import XCTest
import Brick

class SpotsControllerTests : XCTestCase {

  func testSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)

    XCTAssertEqual(spotController.spot as? ListSpot, listSpot)
  }

  func testUpdateSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)
    let items = [ViewModel(title: "item1")]

    spotController.update { spot in
      spot.component.items = items
    }

    XCTAssert(spotController.spot!.component.items == items)
  }

  func testAppendItem() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)

    XCTAssert(spotController.spot!.component.items.count == 0)

    let item = ViewModel(title: "title1", kind: "list")
    spotController.append(item, spotIndex: 0)

    XCTAssert(spotController.spot!.component.items.count == 1)

    if let testItem = spotController.spot!.component.items.first {
      XCTAssert(testItem == item)
    }

    // Test appending item without kind
    spotController.append(ViewModel(title: "title2"), spotIndex: 0) {
      XCTAssert(spotController.spot!.component.items.count == 2)
      XCTAssertEqual(spotController.spot!.component.items[1].title, "title2")
    }
  }

  func testAppendItems() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)

    let items = [
      ViewModel(title: "title1", kind: "list"),
      ViewModel(title: "title2", kind: "list")
    ]
    spotController.append(items, spotIndex: 0)

    XCTAssert(spotController.spot!.component.items.count > 0)
    XCTAssert(spotController.spot!.component.items == items)

    // Test appending items without kind
    spotController.append([
      ViewModel(title: "title3"),
      ViewModel(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(spotController.spot!.component.items.count, 4)
      XCTAssertEqual(spotController.spot!.component.items[2].title, "title3")
      XCTAssertEqual(spotController.spot!.component.items[3].title, "title4")
    }
  }

  func testPrependItems() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)

    let items = [
      ViewModel(title: "title1", kind: "list"),
      ViewModel(title: "title2", kind: "list")
    ]
    spotController.prepend(items, spotIndex: 0)

    XCTAssertEqual(spotController.spot!.component.items.count, 2)
    XCTAssert(spotController.spot!.component.items == items)

    spotController.prepend([
      ViewModel(title: "title3"),
      ViewModel(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(spotController.spot!.component.items[0].title, "title3")
      XCTAssertEqual(spotController.spot!.component.items[1].title, "title4")
    }
  }

  func testDeleteItem() {
    let component = Component(title: "Component", kind: "list", items: [
      ViewModel(title: "title1", kind: "list"),
      ViewModel(title: "title2", kind: "list")
      ])
    let initialListSpot = ListSpot(component: component)

    let spotController = SpotsController(spot: initialListSpot)

    let firstItem = spotController.spot!.component.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let listSpot = (spotController.spot as! ListSpot)
    listSpot.delete(component.items.first!) {
      let lastItem = spotController.spot!.component.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(spotController.spot!.component.items.count, 1)
    }
  }

  func testComputedPropertiesOnSpotable() {
    let component = Component(title: "Component", kind: "list", items: [
      ViewModel(title: "title1", kind: "list"),
      ViewModel(title: "title2", kind: "list")
      ])
    let spot = ListSpot(component: component)

    XCTAssert(spot.items == component.items)

    let newItems = [ViewModel(title: "title3", kind: "list")]
    spot.items = newItems
    XCTAssertFalse(spot.items == component.items)
    XCTAssert(spot.items == newItems)
  }

  func testFindAndFilterSpotWithClosure() {
    let listSpot = ListSpot(component: Component(title: "ListSpot"))
    let listSpot2 = ListSpot(component: Component(title: "ListSpot2"))
    let gridSpot = GridSpot(component: Component(title: "GridSpot", items: [ViewModel(title: "ViewModel")]))
    let spotController = SpotsController(spots: [listSpot, listSpot2, gridSpot])

    XCTAssertNotNil(spotController.spot{ $1.component.title == "ListSpot" })
    XCTAssertNotNil(spotController.spot{ $1.component.title == "GridSpot" })
    XCTAssertNotNil(spotController.spot{ $1 is Listable })
    XCTAssertNotNil(spotController.spot{ $1 is Gridable })
    XCTAssertNotNil(spotController.spot{ $1.items.filter{ $0.title == "ViewModel" }.first != nil })
    XCTAssertEqual(spotController.spot{ $0.index == 0 }?.component.title, "ListSpot")
    XCTAssertEqual(spotController.spot{ $0.index == 1 }?.component.title, "ListSpot2")
    XCTAssertEqual(spotController.spot{ $0.index == 2 }?.component.title, "GridSpot")

    XCTAssert(spotController.filter { $0 is Listable }.count == 2)
  }

  func testJSONInitialiser() {
    let spot = ListSpot()
    spot.items = [ViewModel(title: "First item")]
    let sourceController = SpotsController(spot: spot)
    let jsonController = SpotsController([
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First item"]
          ]
        ]
      ]
      ])

    XCTAssert(sourceController.spot!.component == jsonController.spot!.component)
  }

  func testJSONReload() {
    let initialJSON = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]
    let jsonController = SpotsController(initialJSON)

    XCTAssert(jsonController.spot!.component.kind == "list")
    XCTAssert(jsonController.spot!.component.items.count == 1)
    XCTAssert(jsonController.spot!.component.items.first?.title == "First list item")

    let updateJSON = [
      "components" : [
        ["kind" : "grid",
          "items" : [
            ["title" : "First grid item"],
            ["title" : "Second grid item"]
          ]
        ]
      ]
    ]

    jsonController.reload(updateJSON) {
      XCTAssert(jsonController.spot!.component.kind == "grid")
      XCTAssert(jsonController.spot!.component.items.count == 2)
      XCTAssert(jsonController.spot!.component.items.first?.title == "First grid item")
    }
  }

  func testDictionaryOnSpotsController() {
    let initialJSON = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]
    let firstController = SpotsController(initialJSON)
    let secondController = SpotsController(firstController.dictionary)

    XCTAssertTrue(firstController.spots.first!.component == secondController.spots.first!.component)
  }

  func testReloadIfNeededWithComponents() {
    let initialJSON: [String : AnyObject] = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ],
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]

    let newJSON: [String : AnyObject] = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item 2"],
            [
              "kind" : "composite",
              "items" : [
                ["kind" : "grid",
                  "items" : [
                    ["title" : "First list item"]
                  ]
                ]
              ]
            ]
          ]
        ],
        ["kind" : "grid",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]

    let controller = SpotsController(initialJSON)
    XCTAssertTrue(controller.spots[0] is ListSpot)
    XCTAssertEqual(controller.spots[0].items.first?.title, "First list item")
    XCTAssertEqual(controller.spots[1].items.first?.title, "First list item")
    XCTAssertTrue(controller.spots[1] is ListSpot)
    XCTAssertTrue(controller.spots.count == 2)
    XCTAssertTrue(controller.compositeSpots.count == 0)

    controller.reloadIfNeeded(newJSON) {
      XCTAssertEqual(controller.spots.count, 3)
      XCTAssertTrue(controller.spots[0] is ListSpot)
      XCTAssertTrue(controller.spots[1] is GridSpot)
      XCTAssertEqual(controller.spots[0].items.first?.title, "First list item 2")
      XCTAssertEqual(controller.spots[1].items.first?.title, "First list item")

      XCTAssertEqual(controller.spots[0].items[1].kind, "composite")
      XCTAssertTrue(controller.compositeSpots.count == 1)

      controller.reloadIfNeeded(initialJSON) {
        XCTAssertTrue(controller.spots[0] is ListSpot)
        XCTAssertEqual(controller.spots[0].items.first?.title, "First list item")
        XCTAssertEqual(controller.spots[1].items.first?.title, "First list item")
        XCTAssertTrue(controller.spots[1] is ListSpot)
        XCTAssertTrue(controller.spots.count == 2)
        XCTAssertTrue(controller.compositeSpots.count == 0)
      }
    }
  }
}
