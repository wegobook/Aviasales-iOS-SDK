class HLHotelDetailsRatingDetailsCell: HLHotelDetailsColumnBaseCell {

    private static var cellInstance: HLHotelDetailsColumnBaseCell = {
            let views = Bundle.main.loadNibNamed("HLHotelDetailsRatingDetailsCell", owner: nil, options: nil) as! [UIView]
            return views.first! as! HLHotelDetailsColumnBaseCell
    }()

    @IBOutlet weak var moreButtonLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var moreButton: UIButton!

    @IBOutlet weak var firstRatingView: UIView!
    @IBOutlet weak var firstScoreLabel: UILabel!

    @IBOutlet weak var secondRatingView: UIView!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondScoreLabel: UILabel!
    @IBOutlet weak var threeDotsImageView: UIImageView!

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet var betweenConstraint: NSLayoutConstraint!

    private var moreHandler: (() -> Void)?

    private var showMoreItem = false {
        didSet {
            updateCellStyle()
        }
    }

    class func estimatedHeight(_ first: Bool, last: Bool) -> CGFloat {
        var height: CGFloat = 41.0
        height += first ? 6 : 0.0
        height += last ? 15 : 0.0

        return height
    }

    override var first: Bool {
        didSet {
            self.topConstraint.constant = self.first ? 15.0 : 5
            self.setNeedsLayout()
        }
    }

    override var last: Bool {
        didSet {
            self.bottomConstraint.constant = self.last ? 15.0 : 7
            self.setNeedsLayout()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        firstScoreLabel.font = UIFont.systemFont(ofSize: 14.0)
        secondScoreLabel.font = UIFont.systemFont(ofSize: 14.0)
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)

        firstRatingView.layer.cornerRadius = 15.0
        firstRatingView.clipsToBounds = true
        secondRatingView.layer.cornerRadius = 15.0
        secondRatingView.clipsToBounds = true
    }

    @IBAction func moreButtonTap(_ sender: Any) {
        moreHandler?()
    }

    func configureForRatingDetails(_ ratingDetailsItem: RatingItem) {
        self.firstTitleLabel.text = ratingDetailsItem.name
        self.firstRatingView.backgroundColor = JRColorScheme.ratingColor(ratingDetailsItem.score)
        self.firstScoreLabel.text = StringUtils.shortRatingString(ratingDetailsItem.score)
        showMoreItem = false
        self.columnCellStyle = .oneColumn
    }

    func configureForRatingDetailsPair(_ firstItem: RatingDetailItem, secondItem: RatingDetailItem?) {
        self.firstTitleLabel.text = firstItem.name
        self.firstRatingView.backgroundColor = JRColorScheme.ratingColor(firstItem.score)
        self.firstScoreLabel.text = StringUtils.shortRatingString(firstItem.score)

        self.secondTitleLabel.text = secondItem?.name
        self.secondRatingView.backgroundColor = JRColorScheme.ratingColor(secondItem?.score ?? 0)
        self.secondScoreLabel.text = StringUtils.shortRatingString(secondItem?.score ?? 0)
        self.secondScoreLabel.textColor = UIColor.white
        showMoreItem = false
        self.columnCellStyle = .twoColumns
    }

    func configureForMoreItem(_ moreItem: MoreRatingDetailsItem, columnCellStyle: HLHotelDetailsColumnCellStyle) {
        moreButton.setTitle(moreItem.name, for: .normal)
        moreHandler = moreItem.moreHandler
        showMoreItem = true
        self.columnCellStyle = columnCellStyle
    }

    override func updateCellStyle() {
        let shouldHideSecondColumn = columnCellStyle == .oneColumn || showMoreItem
        secondRatingView.isHidden = shouldHideSecondColumn
        secondTitleLabel.isHidden = shouldHideSecondColumn

        betweenConstraint.isActive = columnCellStyle != .oneColumn

        let shouldHideFirstColumn = columnCellStyle == .oneColumn && showMoreItem
        firstRatingView.isHidden = shouldHideFirstColumn
        firstTitleLabel.isHidden = shouldHideFirstColumn

        moreButton.isHidden = !showMoreItem

        contentView.removeConstraint(moreButtonLeadingConstaint)
        switch columnCellStyle {
        case .oneColumn:
            moreButtonLeadingConstaint = moreButton.autoPinEdge(.leading, to: .leading, of: firstRatingView)
        case .twoColumns:
            moreButtonLeadingConstaint = moreButton.autoPinEdge(.leading, to: .leading, of: secondRatingView)
        }

        setNeedsLayout()
    }

    override class func fakeCellInstance() -> HLHotelDetailsColumnBaseCell {
        return cellInstance
    }

}
