import UIKit

class MultipleLinesFeatureCell: HLAutolayoutCell {

    fileprivate struct Consts {
        static let top: CGFloat = 5
        static let bottom: CGFloat = 5
        static let firstCellTop: CGFloat = 6
        static let lastCellBottom: CGFloat = 16

        static let left: CGFloat = 15
        static let right: CGFloat = 15
        static let beetwen: CGFloat = 15

        static let iconSize: CGFloat = 15
    }

    let titleLabel = UILabel()
    let iconImageView = UIImageView()
    let separatorView = SeparatorView()

    var topConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?

    var isFirst = false {
        didSet {
            topConstraint?.constant = MultipleLinesFeatureCell.topMargin(isFirst)
        }
    }

    var isLast = false {
        didSet {
            bottomConstraint?.constant = -MultipleLinesFeatureCell.bottomMargin(isLast)
            separatorView.isHidden = !isLast
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

    fileprivate func createSubviews() {
        iconImageView.contentMode = .center
        contentView.addSubview(iconImageView)

        titleLabel.font = MultipleLinesFeatureCell.titleFont()
        titleLabel.textColor = JRColorScheme.darkTextColor()
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)

        separatorView.attachToView(contentView, edge: .bottom, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        separatorView.isHidden = true
    }

    fileprivate class func titleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 15.0)
    }

    override func setupConstraints() {
        super.setupConstraints()

        iconImageView.autoSetDimensions(to: CGSize(width: Consts.iconSize, height: Consts.iconSize))
        iconImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: Consts.left)
        iconImageView.autoPinEdge(.top, to: .top, of: titleLabel, withOffset: 2)

        topConstraint = titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: MultipleLinesFeatureCell.topMargin(isFirst))
        bottomConstraint = titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: MultipleLinesFeatureCell.bottomMargin(isLast))
        titleLabel.autoPinEdge(.leading, to: .trailing, of: iconImageView, withOffset: Consts.beetwen)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: Consts.right)
    }

    fileprivate class func topMargin(_ isFirst: Bool) -> CGFloat {
        return isFirst ? Consts.firstCellTop : Consts.top
    }

    fileprivate class func bottomMargin(_ isLast: Bool) -> CGFloat {
        return isLast ? Consts.lastCellBottom : Consts.bottom
    }

    func configure(text: String, icon: UIImage) {
        titleLabel.text = text
        iconImageView.image = icon
    }

    class func preferredHeight(text: String, width: CGFloat, isFirst: Bool, isLast: Bool) -> CGFloat {
        let labelWidth = width - Consts.left - Consts.iconSize - Consts.beetwen - Consts.right
        let textHeight = text.hl_height(attributes: [NSAttributedStringKey.font: titleFont()], width:labelWidth)
        let additionalHeightToMimicFeatureCell: CGFloat = 3

        return textHeight + topMargin(isFirst) + bottomMargin(isLast) + additionalHeightToMimicFeatureCell
    }
}
