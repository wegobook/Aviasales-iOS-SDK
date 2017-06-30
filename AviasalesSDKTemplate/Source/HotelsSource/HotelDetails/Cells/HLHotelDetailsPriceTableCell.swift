class HLHotelDetailsPriceTableCell: HLPriceTableViewCell {
    @IBOutlet weak var backgroundBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var highlightView: UIView!

    var forceTouchAdded = false

    override var last: Bool {
        didSet {
            backgroundBottomConstraint.constant = last ? 15.0 : 10.0
            setNeedsLayout()
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        highlightView.isHidden = !highlighted
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.attachToView(self, edge: .bottom, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        separatorView.isHidden = true
    }

    func configure(for room: HDKRoom, currency: HDKCurrency, duration: Int, shouldShowSeparator: Bool) {
        super.configure(for: room, currency: currency, duration: duration)
        separatorView.isHidden = !shouldShowSeparator
    }

    override var canHighlightDiscount: Bool {
        return false
    }

    override class func logoTopOffset() -> CGFloat {
        return 14.0
    }

    override class func commonLeftOffset() -> CGFloat {
        return 30.0
    }

    override class func contentBottomOffset() -> CGFloat {
        return 25.0
    }

    class func calculateCellHeight(_ tableWidth: CGFloat, room: HDKRoom, currency: HDKCurrency, last: Bool) -> CGFloat {
        return super.calculateCellHeight(tableWidth, room: room, currency: currency) + (last ? 5.0 : 0.0)
    }
}
