class HLHotelDetailsFeaturesCell: HLHotelDetailsColumnBaseCell {

    private static var cellInstance: HLHotelDetailsColumnBaseCell = {
            let views = Bundle.main.loadNibNamed("HLHotelDetailsFeaturesCell", owner: nil, options: nil) as! [UIView]
            return views.first as! HLHotelDetailsColumnBaseCell
        }()

    @IBOutlet fileprivate(set) weak var descriptionLabel: UILabel!

    @IBOutlet fileprivate(set) weak var iconView: UIImageView!
    @IBOutlet fileprivate(set) weak var titleLabel: UILabel!

    @IBOutlet fileprivate(set) weak var firstIconView: UIImageView!
    @IBOutlet fileprivate(set) weak var secondIconView: UIImageView!
    @IBOutlet fileprivate(set) weak var secondTitleLabel: UILabel!

    @IBOutlet fileprivate weak var topConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var betweenFeaturesConstraint: NSLayoutConstraint!

    class func estimatedHeight(_ first: Bool, last: Bool, hasDescription: Bool = false) -> CGFloat {
        var height: CGFloat = 30.0
        height += first ? -2.0 : 0.0
        height += last ? 15.0 : 0.0
        height += hasDescription ? 18.0 : 0.0

        return height
    }

    func configureForAmenity(_ amenity: AmenityItem) {
        self.titleLabel.text = amenity.name
        self.iconView.image = amenity.image
        self.columnCellStyle = .oneColumn
    }

    func configureForAmenityPair(_ firstAmenity: AmenityItem, secondAmenity: AmenityItem?) {
        self.firstTitleLabel.text = firstAmenity.name
        self.firstIconView.image = firstAmenity.image
        self.secondTitleLabel.text = secondAmenity?.name
        self.secondIconView.image = secondAmenity?.image
        self.columnCellStyle = .twoColumns
    }

    func configureForTripTypeItem(_ tripType: TripTypeItem) {
        self.titleLabel.text = tripType.name
        self.iconView.image = tripType.image
        self.columnCellStyle = .oneColumn
    }

    func configureForTripTypeItemPair(_ firstTripTypeItem: TripTypeItem, secondTripType: TripTypeItem?) {
        self.firstTitleLabel.text = firstTripTypeItem.name
        self.firstIconView.image = firstTripTypeItem.image
        self.secondTitleLabel.text = secondTripType?.name
        self.secondIconView.image = secondTripType?.image
        self.columnCellStyle = .twoColumns
    }

    // MARK: - Override methods

    override var first: Bool {
        didSet {
            self.topConstraint.constant = self.first ? 3.0 : 5.0

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        columnCellStyle = .oneColumn
        titleLabel.textColor = JRColorScheme.darkTextColor()
        secondTitleLabel.textColor = JRColorScheme.darkTextColor()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.descriptionLabel.text = nil
    }

    override class func fakeCellInstance() -> HLHotelDetailsColumnBaseCell {
        return cellInstance
    }

    // MARK: - Private methods

    override func updateCellStyle() {
        let shouldHideSecondColumn = self.columnCellStyle == .oneColumn
        self.secondIconView.isHidden = shouldHideSecondColumn
        self.secondTitleLabel.isHidden = shouldHideSecondColumn

        betweenFeaturesConstraint.isActive = !shouldHideSecondColumn
        setNeedsLayout()
    }

}
