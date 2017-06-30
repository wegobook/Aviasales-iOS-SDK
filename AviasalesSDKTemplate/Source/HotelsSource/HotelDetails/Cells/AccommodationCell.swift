class AccommodationCell: HLAutolayoutCell {

    private struct Consts {
        static let top: CGFloat = 8
        static let bottom: CGFloat = 7
        static let firstCellTop: CGFloat = 15
        static let lastCellBottom: CGFloat = 15

        static let between: CGFloat = 10
        static let left: CGFloat = 15
        static let right: CGFloat = 15
    }

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let separatorView = SeparatorView()

    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?

    var first = false {
        didSet {
            topConstraint?.constant = AccommodationCell.topMargin(first)
        }
    }

    var last = false {
        didSet {
            bottomConstraint?.constant = -AccommodationCell.bottomMargin(last)
            separatorView.isHidden = !last
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        createSubviews()
        updateConstraintsIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {
        titleLabel.font = AccommodationCell.titleFont()
        titleLabel.textColor = JRColorScheme.darkTextColor()
        contentView.addSubview(titleLabel)

        valueLabel.font = AccommodationCell.valueFont()
        valueLabel.textAlignment = .right
        valueLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(valueLabel)

        separatorView.attachToView(self, edge: .bottom, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        separatorView.isHidden = false
    }

    private class func titleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 14.0)
    }

    private class func valueFont() -> UIFont {
        return UIFont.systemFont(ofSize: 14.0)
    }

    override func setupConstraints() {
        super.setupConstraints()

        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: Consts.left)
        topConstraint = titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: AccommodationCell.topMargin(first))
        bottomConstraint = titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: AccommodationCell.bottomMargin(last))

        valueLabel.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: Consts.between, relation: .greaterThanOrEqual)
        valueLabel.autoPinEdge(.top, to: .top, of: titleLabel)
        valueLabel.autoPinEdge(.bottom, to: .bottom, of: titleLabel)
        valueLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: Consts.right)

        NSLayoutConstraint.autoSetPriority(UILayoutPriorityDefaultLow + 1) {
            titleLabel.autoSetContentHuggingPriority(for: .horizontal)
        }
    }

    private class func topMargin(_ isFirst: Bool) -> CGFloat {
        return isFirst ? Consts.firstCellTop : Consts.top
    }

    private class func bottomMargin(_ isLast: Bool) -> CGFloat {
        return isLast ? Consts.lastCellBottom : Consts.bottom
    }

    func configure(item: AccommodationItem) {
        titleLabel.text = item.name
        valueLabel.text = item.text
        valueLabel.textColor = item.shouldHighlightText ? JRColorScheme.mainButtonBackgroundColor() : JRColorScheme.darkTextColor()
        first = item.first
        last = item.last
    }

    class func preferredHeight(_ isFirst: Bool, isLast: Bool) -> CGFloat {
        let textHeight: CGFloat = 17
        return textHeight + topMargin(isFirst) + bottomMargin(isLast)
    }

    class func canFill(_ title: String, text: String, cellWidth: CGFloat) -> Bool {
        let titleWidth = title.hl_width(attributes: [NSFontAttributeName: titleFont()], height: 17)
        let textWidth = text.hl_width(attributes: [NSFontAttributeName: titleFont()], height: 17)

        let availableWidth = cellWidth - Consts.left - Consts.between - Consts.right
        return availableWidth > titleWidth + textWidth
    }

}
