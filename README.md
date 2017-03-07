![Spots logo](https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/cover_v6.jpg)
<div align="center">
<a href="https://travis-ci.org/hyperoslo/Spots" target="_blank">
<img src="http://img.shields.io/travis/hyperoslo/Spots.svg?style=flat">
</a>

<a href="http://cocoadocs.org/docsets/Spots" target="_blank">
<img src="https://img.shields.io/cocoapods/v/Spots.svg?style=flat">
</a>

<a href="https://github.com/Carthage/Carthage" target="_blank">
<img src="https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat">
</a>

<a href="http://cocoadocs.org/docsets/Spots" target="_blank">
<img src="https://img.shields.io/cocoapods/l/Spots.svg?style=flat">
</a>

<a href="http://cocoadocs.org/docsets/Spots" target="_blank">
<img src="https://img.shields.io/badge/platform-ios | macos | tvos-lightgrey.svg">
</a>
<br/>
<a href="http://cocoadocs.org/docsets/Spots" target="_blank">
<img src="https://img.shields.io/cocoapods/metrics/doc-percent/Spots.svg?style=flat">
</a>

<a href="https://codecov.io/github/hyperoslo/Spots?branch=master"><img src="https://codecov.io/github/hyperoslo/Spots/coverage.svg?branch=master" alt="Coverage Status" data-canonical-src="https://codecov.io/github/hyperoslo/Spots/coverage.svg?branch=master" style="max-width:100%;"></a>

<img src="https://img.shields.io/badge/%20in-swift%203.0-orange.svg">

<a href="https://gitter.im/hyperoslo/Spots?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge">
<img src="https://badges.gitter.im/hyperoslo/Spots.svg">
</a>
<br><br>
</div>

**Spots** is a cross-platform view controller framework for building component-based UIs. The internal architecture is built using generic view models that can be transformed both to and from JSON. So, moving your UI declaration to a backend is as easy as pie.
Data source and delegate setup is handled by **Spots**, so there is no need for you to do that manually. The public API is jam-packed with convenience methods for performing mutation, it is as easy as working with a regular collection type.

## Table of Contents

<img src="https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/icon_v5.png" alt="Spots Icon" align="right" />

* [Key features](#key-features)
* [Origin Story](#origin-story)
* [Universal support](#universal-support)
* [Why JSON?](#why-json)
* [Composition](#composition)
* [View state caching](#view-state-caching)
* [Live editing](#live-editing)
* [How does it work?](#how-does-it-work)
* [Performing mutation](#performing-mutation)
* [Layout](#layout)
* [Usage](#usage)
* [View models in the Cloud](#view-models-in-the-cloud)
* [Programmatic approach](#programmatic-approach)
* [Controller](#spotscontroller)
* [Delegates](#delegates)
*  [SpotsDelegate](#spotsdelegate)
*  [SpotsRefreshDelegate](#spotsrefreshdelegate)
*  [SpotsScrollDelegate](#spotsscrolldelegate)
*  [SpotsCarouselScrollDelegate](#spotscarouselscrolldelegate)
* [The many faces of Spots](#the-many-faces-of-spots)
* [JSON structure](#json-structure)
* [Models](#models)
* [ComponentModel](#component)
* [Item](#item)
* [Installation](#installation)
* [Dependencies](#dependencies)
* [Author](#author)
* [Credits](#credits)
* [Contributing](#contributing)
* [License](#license)

## Key features

- JSON based views that could be served up by your backend.
- Live editing.
- View based caching for controllers, table and collection views.
- Supports displaying multiple collections, tables and regular views in the same container.
- Features both infinity scrolling and pull to refresh (on iOS), all you have to do is to
setup delegates that conform to the public protocols on `Controller`.
- No need to implement your own data source, every `Spotable` object has their
own set of `Item`’s.
which is maintained internally and is there at your disposable if you decide to
make changes to them.
- Easy configuration of collection views, table views and any custom spot
implementation that you add.
This improves code reuse and helps to theme your app and ultimately keep your application consistent.
- Support custom Spots, all you need to do is to conform to `Spotable`
- A rich public API for appending, prepending, inserting, updating or
deleting `Item`s.
- Features three different spots out-of-the-box; `CarouselSpot`, `GridSpot`, `ListSpot`
- Static custom cell registrations for all `Spotable` objects.
Write one view cell and use it across your application, when and where you
want to use it.
- Cell height caching, this improves performance as each cell has its height stored as a calculated value.
on the view model.
- Supports multiple cell types inside the same data source, no more ugly if-statements in your implementation;
- Soft & hard updates to UI components.
- Supports both views made programmatically and nib-based views.
**Spots** handles this for you by using a cell registry.

## Origin Story

We wrote a Medium article about how and why we built `Spots`.
You can find it here: [Hitting the sweet spot of inspiration](https://medium.com/@zenangst/hitting-the-sweet-spot-of-inspiration-637d387bc629#.b9a1mun2i)

## Universal support

Apple's definition of a universal applications is iPhone and iPad. Spots takes this a step further with one controller tailored to each platform to support all your UI related update needs. Internally, everything conforms to the same shared protocol. What this means for you, is that get a unified experience when developing for iOS, tvOS or macOS.

## Why JSON?

JSON works great as a common transport language, it is platform agnostic and it is something that developers are already using regularly when building application that fetch data from an external resource. **Spots** uses JSON internally to save a snapshot of the view state to disk, the only thing that you have to do is to give the **Controller** a cache key and call save whenever you have performed your update.

So what if I don't have a backend that supports **Spots** view models? Not to worry, you can set up **Spots** programmatically and still use all the other advantages of the framework.

## View state caching

As mentioned above, **Spots** features a view state cache. Instead of saving all your data in a database somewhere and perform queries every time to initiate a view controller, we went with a different and much simpler approach. If a **Controller** has a cache key and you call `save`, internally it will encode all underlaying **Spotable** objects and its children into a JSON file and store that to disk. The uniqueness of the file comes from the cache key, think of this like your screen identifier. The next time you construct a **Controller** with that cache key, it will try to load that from disk and display it the exact same way as it was before saving. The main benefit here is that you don’t have to worry about your object changing by updating to future versions of **Spots**.

**ListSpot**, **GridSpot**, **CarouselSpot** also have support for view state caching because these components can be used separately without using **Controller**.

View state caching is optional but we encourage you to use it, as it renders the need to use a database as optional.

## Composition

A common problem when developing for Apple's platforms is that you often have to choose between which core framework component to base your foundation on. Depending on what you need then and there. This is a not a problem in itself, it becomes a problem when you need to iterate and combine two of them together, like displaying a collection view inside of a table view. This is where composition comes in. Spots supports composition out-of-the box and it is super easy to use and iterate on.

`Item`s inside of a `Spotable` object have a property called `children`. In the case of Spots, children are `ComponentModel`'s that represent other `Spotable` objects. This means that you can easily add a grid, carousel or list inside any `Spotable` object of your choice. On larger screens this becomes incredibly useful as composition can be used as a sane way of laying out your views on screen without the need for child view controllers, unmaintainable auto layout or frame based implementations.

You can create `Spotable` pseudo objects that handle layout, this is especially useful for `Gridable` objects like the `GridSpot`, where you can use `layout.span` to define how many objects should be displayed side-by-side.

Composition is supported on iOS, tvOS and macOS.

## Live editing

As mentioned above, **Spots** internal view state cache uses JSON for saving the state to disk. To leverage even more from JSON, **Spots** has a built-in feature to live edit what you see on screen. If you compile **Spots** with the `-DDEVMODE` flag, **Spots** will monitor the current cache for any changes applied to the view cache. It will also print the current cache path to the console so that you easily grab the file url, open it in your favorite source code editor to play around your view and have it reload whenever you save the file.

*Live editing only works when running your application in the Simulator.*

See [Installation](#installation) for how to enable live editing using CocoaPods.

## How does it work?

At the top level of **Spots**, you have the **Controller** which is the replacement for your view controller.

Inside of the **Controller**, you have a **SpotsScrollView** that handles the linear layout of the components that you add to your data source. It is also in charge of giving the user a unified scrolling experience. Scrolling is disabled on all underlaying components except for components that have horizontal scrolling (e.g **CarouselSpot**).

So how does scrolling work? Whenever a user scrolls, the **SpotsScrollView** computes the offset and size of its children. By using this technique you can easily create screens that contain lists, grids and carousels with a scrolling experience as smooth as proverbial butter. By dynamically changing the size and offset of the children, **SpotsScrollView** also ensures that reusable views are allocated and deallocated like you would expect them to.
**SpotsScrollView** uses KVO on any view that gets added so if one component changes height or position, the entire layout will invalidate itself and redraw it like it was intended.

**Controller** uses one or more **Spotable** objects. **Spotable** is a protocol that all components use to make sure that all layout calculations can be performed. **Spots** comes with three different **Spotable** objects out-of-the-box.
All **Spotable** objects are based around one core UI element.

**ListSpot** is an object that conforms to **Listable**, it has a **ListAdapter** that works as both the data source and delegate for the **ListSpot**. For iOS, **Listable** uses **UITableView** as its UI component, and **NSTableView** on macOS.

**GridSpot** is an object that conforms to **Gridable**, it uses a different adapter than **ListSpot** as it is based on collection views. The adapter used here is **CollectionAdapter**. On iOS and tvOS, **Gridable** uses **UICollectionView** as its UI component and **NSCollectionView** on macOS.

**CarouselSpot** is very similar to **GridSpot**, it shares the same **CollectionAdapter**, the main difference between them is that **CarouselSpot** has scrolling enabled and uses a process for laying its views out on screen.

What all **Spotable** objects have in common is that all of them use the same **ComponentModel** struct to represent themselves. **ComponentModel** has a *kind* property that maps to the UI component that should be used. By just changing the *kind*, you can transform a *list* into a *grid* as fast has you can type it and hit save.

They also share the same **Item** struct for its children.
The child is a data container that includes the size of the view on screen and the remaining information to configure your view.

To add your own view to **Spots**, you need the view to conform to **ItemConfigurable** and inherit from the core class that your component is based on (UITableViewCell on ListSpot, UICollectionViewCell on CarouselSpot and GridSpot).
**ItemConfigurable** requires you to implement one property and one method.

We don’t like to dictate the terms of how you build your views, if you prefer to build them using `.nib` files, you should be free to do so, and with **Spots** you can. The only thing that differs is how you register the view on the component.

```swift
var preferredViewSize: CGSize { get }

func configure(inout item: Item)
```

**preferredViewSize** is exactly what the name implies, it is the preferred size for the view when it should be rendered on screen. We used the prefix `preferred` as it might be different if the view has dynamic height.

Using different heights for different objects can be a hassle in iOS, tvOS and macOS, but not with **Spots**. To set a calculated height based on the **Item** content, you simply set the height back to the *item* when you are done calculating it in *configure(inout item: Item)*.

e.g
```swift
func configure(inout item: Item) {
  textLabel.text = item.title
  textLabel.sizeToFit()
  item.size.height = textLabel.frame.size.height
}
```

**Item** is a struct, but because of the **inout** keyword in the method declaration it can perform mutation and pass that back to the data source. If you prefer the size to be static, you can simply not set the height and **Spots** will handle setting it for you based on the **preferredViewSize**.

When your view conforms to **ItemConfigurable**, you need to register it with a unique identifier for that view.

You register your view on the component that you want to display it in.

```swift
ListSpot.register(view: MyAwesomeView.self, identifier: “my-awesome-view”)
```

For `nib`-based views, you register them like this.

```swift
ListSpot.register(nib: UINib(nibName: "MyAwesomeView", bundle: NSBundle.mainBundle()), identifier: "my-awesome-view")
```

You can also register default views for your component, what it means is that it will be the fallback view for that view if the `identifier` cannot be resolved or the `identifier` is absent.

```swift
ListSpot.register(defaultView: MyAwesomeView.self)
```

As mentioned above, `ListSpot` is based on `UITableView` (and `NSTableView` in macOS).

By letting the data decide which views to use gives you the freedom of displaying anything anywhere, without cluttering your code with dirty if- or switch-statements that are hard to maintain and prone to introduce bugs.

## Performing mutation

It is very common that you need to modify your data source and tell your UI component to either insert, update or delete depending on the action that you performed. This process can be cumbersome, so to help you out, **Spots** has some great convenience methods to help you with this process.

On **Controller** you have simple methods like `reload(withAnimation, completion)` that tells all the **Spotable** objects to reload.

You can reload **Controller** using a collection of **ComponentModel**’s. Internally it will perform a diffing process to pinpoint what changed, in this process it cascades down from component level to item level, and checks all the moving parts, to perform the most appropriate update operation depending on the change. At item level, it will check if the items size changed, if not it will scale down to only run the `configure` method on the view that was affected. This is what we call hard and soft updates, it will reduce the amount of *blinking* that you can normally see in iOS.

A **Controller** can also be reloaded using JSON. It behaves a bit differently than `reloadIfNeeded(withComponentModels)` as it will create new component and diff them towards each other to find out if something changed. If something changed, it will simply replace the old objects with the new ones.

The difference between `reload` and `reloadIfNeeded` methods is that they will only run if change is needed, just like the naming implies.

If you need more fine-grained control by pinpointing an individual spot, we got you covered on this as well. **Controller** has an update method that takes the spot index as its first argument, followed by an animation label to specify which animation to use when doing the update.
The remaining arguments are one mutation closure where you get the **Spotable** object and can perform your updates, and finally one completion closure that will run when your update is performed both on the data source and the UI component.
This method has a corresponding method called `updateIfNeeded`, which applies the update if needed.

You can also `append` `prepend`, `insert`, `update` or `delete` with a series to similar methods that are publicly available on **Controller**.

All methods take an `Item` as their first argument, the second is the index of the **Spotable** object that you want to update. Just like `reload` and `update`, it also has an animation label to give you control over what animation should be used. As an added bonus, these methods also work with multiple items, so instead of passing just one item, you can pass a collection of items that you want to `append`, `prepend` etc.

## Layout

#### Available in version 5.8.x >

Configuring layout for different components can be tricky, Spots helps to solve this problem with a neat and tidy `Layout` struct that lives on `ComponentModel`. It is used to customize your UI related elements. It can set `contentInset`, `sectionInset` and collection view related properties like `minimumInteritemSpacing` and `minimumLineSpacing`. It works great both programmatical and with JSON. It is supported on all three platforms.

```swift
let layout = Layout() {
  $0.span = 3.0
  $0.itemSpacing = 10.0
  $0.lineSpacing = 0.0
  $0.inset = Inset(top: 0, left: 0, bottom: 0, right: 0)
}

let jsonLayout = Layout(
  [
    "span" : 3.0,
    "item-spacing" : 10.0,
    "line-spacing" : 0.0,
    "dynamic-span" : true,
    "inset" : [
      "top" : 10.0,
      "left" : 10.0,
      "bottom" : 10.0,
      "right" : 10.0
    ]
  ]
)
```

**NOTE** If you update to a newer version of Spots, you might want to enable `legacyMapping` on `ComponentModel`.

```swift
ComponentModel.legacyMapping = true
```

## Usage

### View models in the Cloud
```swift
let controller = Controller(json)
navigationController?.pushViewController(controller, animated: true)
```

The JSON data will be parsed into view model data and your view controller is ready to be presented, it is just that easy.

### Programmatic approach
```swift
let myContacts = ComponentModel(title: "My contacts", items: [
  Item(title: "John Hyperseed"),
  Item(title: "Vadym Markov"),
  Item(title: "Ramon Gilabert Llop"),
  Item(title: "Khoa Pham"),
  Item(title: "Christoffer Winterkvist")
])
let listSpot = ListSpot(component: myContacts)
let controller = Controller(spots: [listSpot])

navigationController?.pushViewController(controller, animated: true)
```

## Controller
The `Controller` inherits from `UIViewController` and `NSViewController` but it sports some core features that makes your everyday mundane tasks a thing of the past. `Controller` has four different delegates

## Delegates

### SpotsDelegate

```swift
public protocol SpotsDelegate: class {
  func spotDidSelectItem(spot: Spotable, item: Item)
  func spotsDidChange(spots: [Spotable])
}
```

`spotDidSelectItem` is triggered when a user taps on an item inside of a `Spotable` object. It returns both the `spot` and the `item` to add context to what UI element was touched.

`spotsDidChange` notifies the delegate when the internal `.spots` property changes.

### SpotsRefreshDelegate

```swift
public protocol SpotsRefreshDelegate: class {
  func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?)
}
```

`spotsDidReload` is triggered when a user pulls the `SpotsScrollView` offset above its initial bounds.

### SpotsScrollDelegate

```swift
public protocol SpotsScrollDelegate: class {
  func spotDidReachBeginning(completion: Completion)
  func spotDidReachEnd(completion: (() -> Void)?)
}
```

`spotDidReachBeginning` notifies the delegate when the scrollview has reached the top. This has a default implementation and is rendered optional for anything that conform to `SpotsScrollDelegate`.

`spotDidReachEnd` is triggered when the user scrolls to the end of the `SpotsScrollView`, this can be used to implement infinite scrolling.

### SpotsCarouselScrollDelegate

```swift
public protocol SpotsCarouselScrollDelegate: class {
  func spotDidEndScrolling(spot: Spotable, item: Item)
}
```

`spotDidEndScrolling` is triggered when a user ends scrolling in a carousel, it returns item that is being displayed and the spot to give you the context that you need.

## The many faces of Spots

Because the framework can be used in a wide variety of ways, we have decided to include more than one example project. If you are feeling adventurous, you should take a peek at the [Examples](https://github.com/hyperoslo/Spots/tree/master/Examples) folder.

## JSON structure

```json
{
   "components":[
      {
         "title":"Hyper iOS",
         "type":"list",
         "span":"1",
         "items":[
            {
               "title":"John Hyperseed",
               "subtitle":"Build server",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:1",
               "meta":{
                  "nationality":"Apple"
               }
            },
            {
               "title":"Vadym Markov",
               "subtitle":"iOS Developer",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:2",
               "meta":{
                  "nationality":"Ukrainian"
               }
            },
            {
               "title":"Ramon Gilabert Llop",
               "subtitle":"iOS Developer",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:3",
               "meta":{
                  "nationality":"Catalan"
               }
            },
            {
               "title":"Khoa Pham",
               "subtitle":"iOS Developer",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:4",
               "meta":{
                  "nationality":"Vietnamese"
               }
            },
            {
               "title":"Christoffer Winterkvist",
               "subtitle":"iOS Developer",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:5",
               "meta":{
                  "nationality":"Swedish"
               }
            }
         ]
      }
   ]
}
```

## Models

### ComponentModel

```swift
  public struct ComponentModel: Mappable {
  public var index = 0
  public var title = ""
  public var kind = ""
  public var span: CGFloat = 0
  public var items = [Item]()
  public var size: CGSize?
  public var meta = [String : String]()
}
```

- **.index**
Calculated value to determine the index it has inside of the spot.
- **.title**
This is used as a title in table view view.
- **.kind**
Determines which spot should be used. `carousel`, `list`, `grid` are there by default but you can register your own.
- **.span**
Determines the amount of views that should fit on one row, by default it is set to zero and uses the default flow layout to render collection based views.
- **.size**
Calculated value based on the amount of items and their combined heights.
- **.meta**
Custom data that you are free to use as you like in your implementation.

### Item

```swift
  public struct Item: Mappable {
  public var index = 0
  public var title = ""
  public var subtitle = ""
  public var image = ""
  public var kind = ""
  public var action: String?
  public var size = CGSize(width: 0, height: 0)
  public var meta = [String : AnyObject]()
}
```

- **.index**
Calculated value to determine the index it has inside of the component.
- **.title**
The headline for your data, in a `UITableViewCell` it is normally used for `textLabel.text` but you are free to use it as you like.
- **.subtitle**
Same as for the title, in a `UITableViewCell` it is normally used for `detailTextLabel.text`.
- **.image**
Can be either a URL string or a local string, you can easily determine if it should use a local or remote asset in your view.
- **.kind**
Is used for the `reuseIdentifier` of your `UITableViewCell` or `UICollectionViewCell`.
- **.action**
Action identifier for you to parse and process when a user taps on a list item. We recommend [Compass](https://github.com/hyperoslo/Compass) as centralized navigation system.
- **.size**
Can either inherit from the `UITableViewCell`/`UICollectionViewCell`, or be manually set by the height calculations inside of your view.
- **.meta**
This is used for extra data that you might need access to inside of your view, it can be a hex color, a unique identifer or additional images for your view.

## Installation

**Spots** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Spots'
```

**Spots** is also available through [Carthage](https://github.com/Carthage/Carthage). To install it, add the following to your `Cartfile`:

```ruby
github "hyperoslo/Spots"
```

If you want to enable live editing for you debug target. Add the following to your Podfile:

```ruby
target 'YOUR TARGET HERE' do
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.name == 'Spots'
        target.build_configurations.each do |config|
          if config.name == 'Debug'
            config.build_settings['OTHER_SWIFT_FLAGS'] = '-DDEBUG -DDEVMODE'
            else
            config.build_settings['OTHER_SWIFT_FLAGS'] = ''
          end
        end
      end
    end
  end
end
```

## Dependencies

- **[Cache](https://github.com/hyperoslo/Cache)**
Used for `ComponentModel` and `Item` caching when initializing a `Controller` or `Spotable` object with a cache key.
- **[Tailor](https://github.com/zenangst/Tailor)**
To seamlessly map JSON to both `ComponentModel` and `Item`.

## Author

[Hyper](http://hyper.no) made this with ❤️. If you’re using this library we probably want to [hire you](https://github.com/hyperoslo/iOS-playbook/blob/master/HYPER_RECIPES.md)! Send us an email at ios@hyper.no.

## Contribute

We would love you to contribute to **Spots**, check the [CONTRIBUTING](https://github.com/hyperoslo/Spots/blob/master/CONTRIBUTING.md) file for more info.

## Credits

- The idea behind Spot came from [John Sundell](https://github.com/johnsundell)'s tech talk "ComponentModels & View Models in the Cloud - how Spotify builds native, dynamic UIs".
- [Ole Begemanns](https://github.com/ole/) implementation of [OLEContainerScrollView](https://github.com/ole/OLEContainerScrollView) is the basis for `SpotsScrollView`, we salute you.
Reference: http://oleb.net/blog/2014/05/scrollviews-inside-scrollviews/

## License

**Spots** is available under the MIT license. See the LICENSE file for more info.
