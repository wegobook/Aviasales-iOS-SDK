import Foundation

class WaitingLongSearchCell: HLAutolayoutCollectionViewCell {

    fileprivate struct Consts {
        static let bottomEmptySpaceHeight: CGFloat = 10
        static let leftOffset: CGFloat = 15
        static let rightOffset: CGFloat = 15

        static let titleTopOffset: CGFloat = 10
        static let subtitleTopOffset: CGFloat = 5
        static let subtitleBottomOffset: CGFloat = 15

        static let clockImageHeight: CGFloat = 30
        static let clockImageWidth: CGFloat = 26
        static let clockTopOffset: CGFloat = 15
    }

    let clockImageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let greenBackgroundView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        greenBackgroundView.layer.cornerRadius = 4
        greenBackgroundView.backgroundColor = UIColor.white
        addSubview(greenBackgroundView)

        clockImageView.image = UIImage(named: "waitingClock")
        greenBackgroundView.addSubview(clockImageView)

        titleLabel.textAlignment = .center
        titleLabel.text = WaitingLongSearchCell.titleText()
        titleLabel.font = WaitingLongSearchCell.titleFont()
        greenBackgroundView.addSubview(titleLabel)

        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = WaitingLongSearchCell.subtitleText()
        subtitleLabel.font = WaitingLongSearchCell.subtitleFont()
        greenBackgroundView.addSubview(subtitleLabel)
    }

    override func setupConstraints() {
        greenBackgroundView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: Consts.bottomEmptySpaceHeight, right: 0))

        clockImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        clockImageView.autoPinEdge(toSuperviewEdge: .top, withInset: Consts.clockTopOffset)
        clockImageView.autoSetDimensions(to: CGSize(width: Consts.clockImageWidth, height: Consts.clockImageHeight))

        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: Consts.leftOffset)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: Consts.rightOffset)
        titleLabel.autoPinEdge(.top, to: .bottom, of: clockImageView, withOffset: Consts.titleTopOffset)

        subtitleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: Consts.leftOffset)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: Consts.rightOffset)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: Consts.subtitleTopOffset)
    }

    private class func titleText() -> String {
        return NSLS("HL_WAITING_LONG_SEARCH_TITLE")
    }

    private class func subtitleText() -> String {
        return NSLS("HL_WAITING_LONG_SEARCH_SUBTITLE")
    }

    private class func titleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 15.0)
    }

    private class func subtitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 12.0)
    }

    class func preferredHeight(containerWidth: CGFloat) -> CGFloat {
        let maxTextWidth = containerWidth - Consts.leftOffset - Consts.rightOffset
        let titleHeight = titleText().hl_height(attributes: [NSAttributedStringKey.font: titleFont()], width: maxTextWidth)
        let subtitleHeight = subtitleText().hl_height(attributes: [NSAttributedStringKey.font: subtitleFont()], width: maxTextWidth)

        return titleHeight + subtitleHeight +
            Consts.clockTopOffset + Consts.clockImageHeight +
            Consts.titleTopOffset + Consts.subtitleTopOffset +
            Consts.subtitleBottomOffset + Consts.bottomEmptySpaceHeight

    }

}
