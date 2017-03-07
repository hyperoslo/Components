/// A JSON to UI parser to produce components for Controller
public struct Parser {

  /// Parse JSON into a collection of Spotable objects with key.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of spotable objects
  public static func parse(_ json: [String : Any], key: String = "components") -> [Spotable] {
    var components: [ComponentModel] = parse(json, key: key)

    for (index, _) in components.enumerated() {
      components[index].index = index
    }

    return components.map {
      Factory.resolve(component: $0)
    }
  }

  /// Parse JSON into a collection of ComponentModels.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of `ComponentModel`s
  public static func parse(_ json: [String : Any], key: String = "components") -> [ComponentModel] {
    guard let payloads = json[key] as? [[String : Any]] else { return [] }

    var components = [ComponentModel]()

    for (index, payload) in payloads.enumerated() {
      var component = ComponentModel(payload)
      component.index = index
      components.append(component)
    }

    return components
  }

  /// Parse JSON into a collection of ComponentModels.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of `ComponentModel`s
  public static func parse(_ json: [String : Any]?, key: String = "components") -> [ComponentModel] {
    guard let payload = json else { return [] }

    return Parser.parse(payload)
  }

  /// Parse JSON into a collection of Spotable objects.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  ///
  /// - returns: A collection of spotable objects
  public static func parse(_ json: [[String : Any]]?) -> [Spotable] {
    guard let json = json else { return [] }

    return json.map {
      Factory.resolve(component: ComponentModel($0))
    }
  }

  public static func parse(_ components: [ComponentModel]) -> [Spotable] {
    return components.map {
      Factory.resolve(component: $0)
    }
  }

  /// Parse view model children into Spotable objects
  /// - parameter item: A view model with children
  ///
  ///  - returns: A collection of Spotable objects
  public static func parse(_ item: ContentModel) -> [Spotable] {
    let spots: [Spotable] = Parser.parse(item.children)
    return spots
  }
}
