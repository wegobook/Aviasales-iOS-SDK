class DiscountInfoView: HLAutolayoutView {

    fileprivate struct Consts {
        static let backgroundHorizontalMargin: CGFloat = 15
        static let right: CGFloat = 15
        static let textHorizontalMargin: CGFloat = 15
        static let backgroundTop: CGFloat = 13
        static let textTop: CGFloat = 22
        static let between: CGFloat = 3
        static let textBottom: CGFloat = 10
        static let backgroundbottom: CGFloat = 0
    }

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let backgroundRoundView = UIView()

    override func initialize() {
        createSubviews()
        updateConstraintsIfNeeded()
    }

    private func createSubviews() {
        backgroundRoundView.backgroundColor = UIColor(hex: 0xEFF3F5)
        backgroundRoundView.layer.cornerRadius = 6
        addSubview(backgroundRoundView)

        titleLabel.font = DiscountInfoView.titleFont()
        titleLabel.textColor = JRColorScheme.discountColor()
        addSubview(titleLabel)

        subtitleLabel.font = DiscountInfoView.subtitleFont()
        subtitleLabel.textColor = JRColorScheme.lightTextColor()
        subtitleLabel.numberOfLines = 0
        addSubview(subtitleLabel)
    }

    fileprivate class func titleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
    }

    fileprivate class func subtitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 13)
    }

    override func setupConstraints() {
        super.setupConstraints()

        let insets = UIEdgeInsets(top: Consts.backgroundTop, left: Consts.backgroundHorizontalMargin, bottom: Consts.backgroundbottom, right: Consts.backgroundHorizontalMargin)
        backgroundRoundView.autoPinEdgesToSuperviewEdges(with: insets)

        titleLabel.autoPinEdge(.leading, to: .leading, of: backgroundRoundView, withOffset: Consts.textHorizontalMargin)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: Consts.textTop)

        subtitleLabel.autoPinEdge(.leading, to: .leading, of: backgroundRoundView, withOffset: Consts.textHorizontalMargin)
        subtitleLabel.autoPinEdge(.trailing, to: .trailing, of: backgroundRoundView, withOffset: -Consts.textHorizontalMargin)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: Consts.between)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: Consts.textBottom)
    }

    func configure(for room: HDKRoom, currency: HDKCurrency, duration: Int) {
        titleLabel.text = DiscountInfoView.titleText(room: room)
        subtitleLabel.text = DiscountInfoView.subtitleText(room: room, currency: currency, duration: duration)
    }

    class func titleText(room: HDKRoom) -> String {
        let format = NSLS("HL_HOTEL_DETAIL_DISCOUNT_PERCENT")
        let discount = "\(abs(room.discount))%"
        return String(format: format, discount)
    }

    class func subtitleText(room: HDKRoom, currency: HDKCurrency, duration: Int) -> String {
        var format, price: String
        format = NSLSP("HL_HOTEL_DETAIL_DISCOUNT_OLD_PRICE", Float(duration))
        price = StringUtils.priceString(withPrice: room.oldPrice, currency: currency)

        return String(format: format, price, duration)
    }

    class func preferredHeight(containerWidth: CGFloat, room: HDKRoom, currency: HDKCurrency, duration: Int) -> CGFloat {
        let textWidth = containerWidth - Consts.backgroundHorizontalMargin * 2 - Consts.textHorizontalMargin * 2

        let titleHeight = titleText(room: room).hl_height(attributes: [NSAttributedStringKey.font: titleFont()], width: textWidth)
        let attr = [NSAttributedStringKey.font: subtitleFont()]
        let subtitle = subtitleText(room: room, currency: currency, duration: duration)
        let subtitleHeight = subtitle.hl_height(attributes: attr, width: textWidth)

        return titleHeight + subtitleHeight + Consts.textTop + Consts.between + Consts.textBottom
    }

}
