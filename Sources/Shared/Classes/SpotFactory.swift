public struct Factory {

  /// The default spot for the Factory
  public static var DefaultSpot: Spotable.Type = GridSpot.self

  /// Defaults spots, it includes carousel, list, grid and view
  private static var spots: [String: Spotable.Type] = [
    ComponentModel.Kind.carousel.string: CarouselSpot.self,
    ComponentModel.Kind.list.string: ListSpot.self,
    ComponentModel.Kind.grid.string: GridSpot.self,
    ComponentModel.Kind.row.string: RowSpot.self,
    ComponentModel.Kind.view.string: ViewSpot.self,
    ComponentModel.Kind.spot.string: Spot.self
  ]

  /// Register a spot for a specfic spot type
  ///
  /// - parameter kind: The reusable identifier that will be used to indentify your view
  /// - parameter spot: A generic spotable type
  public static func register<T: Spotable>(kind: String, spot: T.Type) {
    spots[kind] = spot
  }

  /// Craft spotable object from component struct
  ///
  /// - parameter component: A compontent struct used for crafting the spotable object.
  ///
  /// - returns: A spotable object.
  public static func resolve(component: ComponentModel) -> Spotable {
    var resolvedKind = component.kind
    if component.isHybrid {
      resolvedKind = ComponentModel.Kind.spot.string
    }

    let spot: Spotable.Type = spots[resolvedKind] ?? DefaultSpot

    return spot.init(component: component)
  }
}
