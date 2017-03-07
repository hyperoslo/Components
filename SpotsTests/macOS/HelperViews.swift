import Cocoa
import Spots

class HeaderView: NSView, ContentConfigurable, Componentable {

  var preferredHeaderHeight: CGFloat = 50
  var preferredViewSize: CGSize = CGSize(width: 200, height: 50)

  lazy var titleLabel: NSTextField = {
    let label = NSTextField()
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)

    wantsLayer = true
    layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.25).cgColor

    configureConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
  }

  func configure(_ item: inout Item) {
    titleLabel.stringValue = item.title
  }

  func configure(_ component: ComponentModel) {
    titleLabel.stringValue = component.title
  }
}

class TextView: NSView, ContentConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 200, height: 50)

  lazy var titleLabel: NSTextField = {
    let label = NSTextField()
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)

    wantsLayer = true
    layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.25).cgColor

    configureConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
  }

  func configure(_ item: inout Item) {
    titleLabel.stringValue = item.title
  }
}

class FooterView: NSView, ContentConfigurable, Componentable {

  var preferredHeaderHeight: CGFloat = 50
  var preferredViewSize: CGSize = CGSize(width: 200, height: 50)

  lazy var titleLabel: NSTextField = {
    let label = NSTextField()
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)

    wantsLayer = true
    layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.25).cgColor

    configureConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
  }

  func configure(_ item: inout Item) {
    titleLabel.stringValue = item.title
  }

  func configure(_ component: ComponentModel) {
    titleLabel.stringValue = component.title
  }
}
