class HLHotelDetailsImportantPoiCell: HLHotelDetailsTableCell {

    private static var cellInstance: HLHotelDetailsImportantPoiCell = {
        return loadViewFromNibNamed(HLHotelDetailsImportantPoiCell.hl_reuseIdentifier()) as! HLHotelDetailsImportantPoiCell
    }()

    @IBOutlet fileprivate(set) weak var iconView: UIImageView!
    @IBOutlet fileprivate(set) weak var titleLabel: UILabel!
    @IBOutlet fileprivate(set) weak var distanceLabel: UILabel!
    @IBOutlet fileprivate weak var topConstraint: NSLayoutConstraint!

    class func estimatedHeight(_ width: CGFloat, first: Bool, last: Bool) -> CGFloat {
        let cell = cellInstance
        let font: UIFont = cell.titleLabel.font!
        let textWidth = width - 60.0
        let string: NSString = "Text"

        var height = string.hl_height(attributes: [NSAttributedStringKey.font : font], width: textWidth)
        height += first ? 16.0 : 5.0
        height += last ? 20.0 : 7.0
        return height
    }

    override var first: Bool {
        didSet {
            self.topConstraint.constant = self.first ? 16.0 : 5.0

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    func setup(_ poi: HDKLocationPoint, variant: HLResultVariant) {
        self.distanceLabel.text = StringUtils.roundedDistance(withMeters: CGFloat(poi.distanceToHotel))
        self.iconView.image = HLPoiIconSelector.listPoiIcon(poi, city: variant.hotel.city)
        self.titleLabel.text = StringUtils.locationPointName(poi)
    }
}
