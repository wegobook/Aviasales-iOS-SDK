class HLPriceTableViewCell: HLHotelDetailsTableCell {

    @IBOutlet private weak var gateImageView: UIImageView!
    @IBOutlet private weak var gateNameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var optionsContainerView: UIView!
    @IBOutlet private weak var lightningImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var optionsContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var betweenDescriptionAndOptionsConstraint: NSLayoutConstraint!

    fileprivate static let descriptionBottomOffset: CGFloat = 10.0
    fileprivate static let optionLabelHeight: CGFloat = 15.0
    fileprivate static let descriptionLabelFont = UIFont.systemFont(ofSize: 15)
    fileprivate static let optionFont = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)

    fileprivate static let logoHeight: CGFloat = 18.0

    static fileprivate var calculatedDescriptionLabelWidth: CGFloat = 0.0

    var currency: HDKCurrency!
    var duration: Int!
    var room: HDKRoom!
    var canHighlightPrivatePrice = true

    private var freeOptionViews = [HLBadgeLabel]()

    var canHighlightDiscount: Bool {
        return false
    }

    class func logoTopOffset() -> CGFloat {
        return 8.0
    }

    class func commonLeftOffset() -> CGFloat {
        return 15.0
    }

    class func contentBottomOffset() -> CGFloat {
        return 15.0
    }

    class func logoBottomOffset() -> CGFloat {
        return 13.0
    }

    class func calculateCellHeight(_ tableWidth: CGFloat, room: HDKRoom, currency: HDKCurrency) -> CGFloat {
        let widthLimit = maxDescriptionLabelWidth(tableWidth)
        let optionsRects = createOptionsRects(room, widthLimit: widthLimit)

        let options = [NSAttributedStringKey.font: descriptionLabelFont]
        var height: CGFloat = logoTopOffset() + logoHeight + logoBottomOffset()
        height += room.name.hl_height(attributes: options, width: widthLimit)

        height += ceil(UIView.packRects(optionsRects, widthLimit: widthLimit, rowOffset: 6.0, horizontalOffset: 15.0, shouldSort: false))
        height += (optionsRects.count > 0) ? descriptionBottomOffset : 0.0
        height += contentBottomOffset()

        return height
    }

    class func maxDescriptionLabelWidth(_ tableWidth: CGFloat) -> CGFloat {
        calculatedDescriptionLabelWidth = tableWidth - 2 * commonLeftOffset()

        return calculatedDescriptionLabelWidth
    }

    class func createOptionsRects(_ room: HDKRoom, widthLimit: CGFloat) -> [CGRect] {
        var rects: [CGRect] = []
        let optionItems = PriceLabelsFactory.current.optionItems(from: room)
        for item in optionItems {
            rects.append(createOptionRect(item.text, font: optionFont, widthLimit: widthLimit))
        }

        return rects
    }

    private class func createOptionRect(_ text: String, font: UIFont, widthLimit: CGFloat) -> CGRect {
        let height = optionLabelHeight
        let inset: CGFloat = 18.0
        var width = text.hl_width(attributes: [NSAttributedStringKey.font: font], height: height)
        width = min(width + inset, widthLimit)

        return CGRect(x: 0.0, y: 0.0, width: width, height: height)
    }

    class var privateFarePriceLabelColor: UIColor {
        return UIColor(red: 208.0/255.0, green: 2.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    }

    func configure(for room: HDKRoom, currency: HDKCurrency, duration: Int) {
        layoutIfNeeded()

        self.room = room
        self.currency = currency
        self.duration = duration

        descriptionLabel.text = room.name
        reloadOptionsView()
        if let gateId = Int(room.gate.gateId) {
            updateGateIcon(gateId)
        }
    }

    func createOptionsViews(_ room: HDKRoom, widthLimit: CGFloat) -> [UIView] {
        var optionViews: [UIView] = []
        let optionItems = PriceLabelsFactory.current.optionItems(from: room)
        for item in optionItems {
            optionViews.append(createOptionView(item.text, icon: item.icon, widthLimit: widthLimit, textColor: item.textColor))
        }

        return optionViews
    }

    private func createOptionView(_ text: String, icon: UIImage, widthLimit: CGFloat, textColor: UIColor) -> UIView {
        let label = freeOptionViews.popLast() ?? HLBadgeLabel(frame: CGRect.zero)
        label.font =  HLPriceTableViewCell.optionFont
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.text = text
        label.insets = UIEdgeInsets(top: 0.0, left: icon.size.width + 6.0, bottom: 0.0, right: 0.0)
        label.textColor = textColor

        let inset: CGFloat = icon.size.width + 6.0
        let height = HLPriceTableViewCell.optionLabelHeight
        let size = label.sizeThatFits(CGSize(width: widthLimit, height: height))
        let width = (size.width + inset) > widthLimit ? widthLimit : (size.width + inset)
        label.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)

        label.configure(forIcon: icon)

        return label
    }

    func updateGateIcon(_ gateId: Int) {
        sd_cancelImageLoadOperation(withKey: "HLGateIconLoad")
        gateNameLabel.text = room.gate.name
        let url = HLUrlUtils.gateIconURL(gateId, size: gateImageView.frame.size, alignment: .left)
        gateImageView.hl_setImageAndHideLabelWithFadeForUrl(url, label: gateNameLabel)
    }

    // MARK: - Override methods

    override func layoutSubviews() {
        super.layoutSubviews()

        reloadOptionsView()
    }

    // MARK: - Private methods

    private func addOptionsViews(_ views: [UIView]) {
        for view in optionsContainerView.subviews {
            view.removeFromSuperview()
        }

        for view in views {
            optionsContainerView.addSubview(view)
        }
    }

    func reloadOptionsView() {
        if let room = room, let currency = currency {
            lightningImageView.isHidden = !room.hasPrivatePriceHighlight() ||
                !canHighlightPrivatePrice ||
                (room.hasDiscountHighlight() && canHighlightDiscount)

            let priceString = StringUtils.attributedPriceString(withPrice: room.price, currency: currency, font: priceLabel.font)
            priceLabel.attributedText = priceString
            priceLabel.textColor = priceTextColor(room)

            self.optionsContainerView.backgroundColor = UIColor.clear
            let width = type(of: self).calculatedDescriptionLabelWidth
            markOptionViewsAsFree()
            let optionsViews = createOptionsViews(room, widthLimit: width)
            let optionsContainerHeight = UIView.packViews(optionsViews, widthLimit: width, rowOffset:6.0, horizontalOffset: 15.0, shouldSort: false)
            optionsContainerHeightConstraint.constant = optionsContainerHeight
            betweenDescriptionAndOptionsConstraint.constant = optionsViews.count > 0
                ? HLPriceTableViewCell.descriptionBottomOffset
                : 0

            addOptionsViews(optionsViews)
        }
    }

    private func markOptionViewsAsFree() {
        for view in optionsContainerView.subviews where view is HLBadgeLabel {
            freeOptionViews.append(view as! HLBadgeLabel)
        }
    }

    private func priceTextColor(_ room: HDKRoom) -> UIColor {
        if room.hasPrivatePriceHighlight() && canHighlightPrivatePrice {
            return JRColorScheme.actionColor()
        }

        return JRColorScheme.actionColor()
    }

}
