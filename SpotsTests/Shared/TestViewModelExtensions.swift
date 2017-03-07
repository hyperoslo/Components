@testable import Spots
import Foundation
import XCTest

class ItemExtensionsTests: XCTestCase {

  func testEvaluateChanges() {
    /*
     Check .New and .Removed
     */

    var oldJSON: [[String : Any]] = [
      ["title": "foo"],
      ["title": "bar"],
    ]

    var newJSON: [[String : Any]] = [
      ["title": "foo"],
      ["title": "bar"],
      ["title": "baz"]
    ]

    var newModels = newJSON.map { ContentModel($0) }
    var oldModels = oldJSON.map { ContentModel($0) }
    XCTAssertEqual(newModels.count, 3)
    XCTAssertEqual(oldModels.count, 2)

    var changes = ContentModel.evaluate(newModels, oldModels: oldModels)
    XCTAssertEqual(changes![0], ItemDiff.none)
    XCTAssertEqual(changes![1], ItemDiff.none)
    XCTAssertEqual(changes![2], ItemDiff.new)

    var processedChanges = ContentModel.processChanges(changes!)
    XCTAssertEqual(processedChanges.insertions.count, 1)
    XCTAssertEqual(processedChanges.updates.count, 0)
    XCTAssertEqual(processedChanges.reloads.count, 0)
    XCTAssertEqual(processedChanges.deletions.count, 0)

    changes = ContentModel.evaluate(oldModels, oldModels: newModels)
    XCTAssertEqual(changes![0], ItemDiff.none)
    XCTAssertEqual(changes![1], ItemDiff.none)
    XCTAssertEqual(changes![2], ItemDiff.removed)

    processedChanges = ContentModel.processChanges(changes!)
    XCTAssertEqual(processedChanges.insertions.count, 0)
    XCTAssertEqual(processedChanges.updates.count, 0)
    XCTAssertEqual(processedChanges.reloads.count, 0)
    XCTAssertEqual(processedChanges.deletions.count, 1)

    /*
     Check that kind takes precedence over title
     */
    oldJSON = [
      ["title": "foo", "kind": "course-item"],
      ["title": "bar", "kind": "list-item"],
    ]
    newJSON = [
      ["title": "foo1", "kind": "course-item"],
      ["title": "bar1", "kind": "grid-item"],
    ]

    newModels = newJSON.map { ContentModel($0) }
    oldModels = oldJSON.map { ContentModel($0) }

    changes = ContentModel.evaluate(newModels, oldModels: oldModels)
    XCTAssertEqual(changes![0], ItemDiff.title)
    XCTAssertEqual(changes![1], ItemDiff.kind)

    processedChanges = ContentModel.processChanges(changes!)
    XCTAssertEqual(processedChanges.insertions.count, 0)
    XCTAssertEqual(processedChanges.updates.count, 1)
    XCTAssertEqual(processedChanges.reloads.count, 1)
    XCTAssertEqual(processedChanges.deletions.count, 0)

    /*
     Diff text attribute on item
     */

    oldJSON = [
      ["text": "foo"],
      ["text": "bar"]
    ]
    newJSON = [
      ["text": "foo"],
      ["text": "baz"]
    ]

    newModels = newJSON.map { ContentModel($0) }
    oldModels = oldJSON.map { ContentModel($0) }
    changes = ContentModel.evaluate(newModels, oldModels: oldModels)
    XCTAssertEqual(changes![0], ItemDiff.none)
    XCTAssertEqual(changes![1], ItemDiff.text)

    processedChanges = ContentModel.processChanges(changes!)
    XCTAssertEqual(processedChanges.insertions.count, 0)
    XCTAssertEqual(processedChanges.updates.count, 1)
    XCTAssertEqual(processedChanges.reloads.count, 0)
    XCTAssertEqual(processedChanges.deletions.count, 0)
  }
}
