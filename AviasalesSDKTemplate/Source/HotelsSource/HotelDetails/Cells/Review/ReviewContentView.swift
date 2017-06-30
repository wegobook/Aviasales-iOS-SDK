import Foundation

enum ReviewStyle {
    case positive
    case negative
    case neutral

    func iconImage() -> UIImage? {
        switch self {
        case .positive: return UIImage(named: "reviewPlusIcon")
        case .negative: return UIImage(named: "reviewMinusIcon")
        case .neutral: return nil
        }
    }
}

class ReviewContentView: HLAutolayoutView {

    let label = UILabel()
    let iconImageView = UIImageView()

    var style: ReviewStyle = .neutral {
        didSet {
            iconImageView.image = style.iconImage()
        }
    }

    convenience init(style: ReviewStyle) {
        self.init()
        self.style = style
        iconImageView.image = style.iconImage()
    }

    override func initialize() {
        setupSubviews()
    }

    func setupSubviews() {
        label.textColor = JRColorScheme.darkTextColor()
        label.font = ReviewContentView.textFont()
        label.numberOfLines = 0
        addSubview(label)

        addSubview(iconImageView)
    }

    override func setupConstraints() {
        iconImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 7)
        iconImageView.autoPinEdge(.top, to: .top, of: label, withOffset: 1)
        iconImageView.autoSetDimensions(to: CGSize(width: 15, height: 15))

        label.autoPinEdge(.leading, to: .trailing, of: iconImageView, withOffset: 15)
        label.autoPinEdge(toSuperviewEdge: .trailing)
        label.autoPinEdge(toSuperviewEdge: .bottom)
        label.autoPinEdge(toSuperviewEdge: .top)
    }

    func configure(forText text: String) {
        label.text = text
    }

    private static func textFont() -> UIFont {
        return UIFont.systemFont(ofSize: 15.0)
    }
}
