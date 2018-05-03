class HLHotelDetailsUsefullInfoCell: HLHotelDetailsTableCell {

    private static var cellInstance: HLHotelDetailsUsefullInfoCell = {
            return loadViewFromNibNamed("HLHotelDetailsUsefullInfoCell") as! HLHotelDetailsUsefullInfoCell
        }()

    var score: Int = 0 {
        didSet {
            self.updateLegendImage()
        }
    }

    var labelText: String? {
        didSet {
            self.label.text = self.labelText

            self.setNeedsLayout()
            self.layoutIfNeeded()

            self.updateLegendImage()
        }
    }

    @IBOutlet fileprivate weak var label: UILabel!
    @IBOutlet fileprivate weak var legendImageView: UIImageView!
    @IBOutlet fileprivate weak var topConstraint: NSLayoutConstraint!

    // MARK: - Class methods

    class func estimatedHeight(_ width: CGFloat, text: String, first: Bool, last: Bool) -> CGFloat {
        let cell = cellInstance
        let font: UIFont = cell.label.font!
        let textWidth = width - 60.0
        let string: NSString = text as NSString

        var height = string.hl_height(attributes: [NSAttributedStringKey.font : font], width: textWidth)
        let kTopMargin: CGFloat = 6.0
        height += kTopMargin
        height += last ? 22.0 : 6.0

        return height
    }

    // MARK: - Override methods

    override func awakeFromNib() {
        super.awakeFromNib()

        self.leftContentOffset?.constant = 50.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.setNeedsLayout()
        self.label.layoutIfNeeded()
        self.label.preferredMaxLayoutWidth = self.label.bounds.width
        self.updateLegendImage()
    }

    // MARK: - Private methos

    fileprivate func updateLegendImage() {
        self.legendImageView.image = UIImage.fixedImageByScore(self.score)
    }

}
