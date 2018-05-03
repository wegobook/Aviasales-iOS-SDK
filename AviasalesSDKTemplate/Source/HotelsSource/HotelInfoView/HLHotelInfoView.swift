@objc enum HLHotelInfoStyle: Int {
    case `default` = 0
    case peek
    case small
}

@objcMembers
@IBDesignable class HLHotelInfoView: UIView {

    @IBOutlet fileprivate weak var starsView: UIView!
    @IBOutlet fileprivate weak var apartmentsLabel: UILabel!
    @IBOutlet fileprivate weak var hotelNameLabel: UILabel!

    @IBOutlet fileprivate weak var starsViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var starsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var hotelNameLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var hotelNameLabelBottomConstraint: NSLayoutConstraint!

    fileprivate let starsOffset: CGFloat = 2.0
    fileprivate let controlsAnimationDuration: TimeInterval = 0.15

    fileprivate let hotelNameBottomConstraintValueSmall: CGFloat = 22.0
    fileprivate let hotelNameBottomConstraintValueBig: CGFloat = 32.0

    fileprivate let starsViewBottomConstraintValueSmall: CGFloat = 10.0
    fileprivate let starsViewBottomConstraintValueBig: CGFloat = 15.0

    fileprivate let hotelNameLeftConstraintValueSmall: CGFloat = 10.0
    fileprivate let hotelNameLeftConstraintValueBig: CGFloat = 15.0

    fileprivate let infoViewLogic = HotelInfoViewLogic()

    var style: HLHotelInfoStyle = .default {
        didSet {
            updateControls()
        }
    }

    var hotel: HDKHotel? {
        didSet {
            updateControls()
        }
    }

    // MARK: - Override methods

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        initialize()
    }

    // MARK: - Internal methods

    func updateControls() {
        guard let hotel = self.hotel else { return }

        if hotel.isValid() {
            applyStyle()
            drawStars()
            updateHotelName()
        }
    }

    // MARK: - Show/Hide controls

    func showInfoControls(animated: Bool) {
        setControlsAlpha(1.0, animated: animated)
    }

    func hideInfoControls(animated: Bool) {
        setControlsAlpha(0.0, animated: animated)
    }

    private func setControlsAlpha(_ alpha: CGFloat, animated: Bool) {
        let duration = animated ? controlsAnimationDuration : 0.0

        UIView.animate(withDuration: duration,
                       animations: { () -> Void in
                        self.starsView.alpha = alpha
                        self.apartmentsLabel.alpha = alpha
                        self.hotelNameLabel.alpha = alpha
            }, completion: nil)
    }

    // MARK: - Private methods

    fileprivate func initialize() {
        let view = loadViewFromNib("HLHotelInfoView", self)!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
    }

    fileprivate func applyStyle() {
        switch style {
        case .default:
            hotelNameLabel.font = UIFont.systemFont(ofSize: 14.0)
            hotelNameLabel.textColor = UIColor.white
            starsViewBottomConstraint.constant = starsViewBottomConstraintValueBig
            hotelNameLabelBottomConstraint.constant = hotelNameBottomConstraintValueBig
            hotelNameLabelLeftConstraint.constant = hotelNameLeftConstraintValueBig

        case .peek:
            hotelNameLabel.font = UIFont.systemFont(ofSize: 14.0)
            hotelNameLabel.textColor = JRColorScheme.darkTextColor()
            apartmentsLabel.textColor = JRColorScheme.darkTextColor()
            starsViewBottomConstraint.constant = 0.0
            hotelNameLabelBottomConstraint.constant = 17.0
            hotelNameLabelLeftConstraint.constant = hotelNameLeftConstraintValueBig

        case .small:
            hotelNameLabel.font = UIFont.systemFont(ofSize: 14.0)
            hotelNameLabel.textColor = UIColor.white
            starsViewBottomConstraint.constant = starsViewBottomConstraintValueSmall
            hotelNameLabelBottomConstraint.constant = hotelNameBottomConstraintValueSmall
            hotelNameLabelLeftConstraint.constant = hotelNameLeftConstraintValueSmall
        }
    }

    fileprivate func drawStars() {

        guard let hotel = self.hotel else { return }

        if infoViewLogic.shouldHideStars(hotel) {
            starsView.isHidden = true
            apartmentsLabel.isHidden = false
            apartmentsLabel.text = infoViewLogic.hotelTypeDescription(hotel)
        } else {
            let count = hotel.stars
            let width = UIImage.whiteStar.size.width
            let point = CGPoint(x: 0.0, y: self.starsView.bounds.midY)

            switch self.style {
            case .default:
                starsView.drawWhiteStars(count, fromPoint: point, offset: starsOffset)
            case .peek:
                starsView.drawYellowStars(count, fromPoint: point, offset: starsOffset)
            case .small:
                starsView.drawSmallWhiteStars(count, fromPoint: point, offset: starsOffset)
            }

            starsViewWidthConstraint.constant = 5.0 * width + 4.0 * self.starsOffset
            starsView.isHidden = false
            apartmentsLabel.isHidden = true
        }
    }

    fileprivate func updateHotelName() {
        if let name = hotel?.name, name.count > 0 {
            self.hotelNameLabel.text = name.capitalized
            self.hotelNameLabel.isHidden = false
        } else {
            self.hotelNameLabel.isHidden = true
        }
    }

}
