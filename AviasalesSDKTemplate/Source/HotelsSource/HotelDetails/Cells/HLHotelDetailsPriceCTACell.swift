class HLHotelDetailsPriceCTACell: HLPriceTableViewCell {

    var bookHandler: (() -> Void)!
    var photoHandler: (() -> Void)!

    @IBOutlet weak var discountInfoView: DiscountInfoView!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet var photoButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var spaceBetweenButtonsConstraint: NSLayoutConstraint!

    @IBAction fileprivate func bookButtonPressed(_ sender: AnyObject) {
        bookHandler()
    }

    @IBAction fileprivate func photoButtonPressed(_ sender: AnyObject) {
        photoHandler()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        bookButton.setTitle(NSLS("HL_HOTEL_DETAIL_BOOK_BUTTON_TITLE"), for: .normal)
        bookButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        bookButton.backgroundColor = JRColorScheme.actionColor()

        photoButton.setTitle(NSLS("HL_HOTEL_DETAIL_PHOTOS_BUTTON_TITLE"), for: .normal)
        photoButton.setTitleColor(JRColorScheme.actionColor(), for: .normal)
        photoButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        photoButton.layer.borderWidth = 1
        photoButton.layer.borderColor = JRColorScheme.actionColor().cgColor
    }

    func hidePhotosButton() {
        photoButtonWidthConstraint.isActive = false
        spaceBetweenButtonsConstraint.isActive = false
    }

    func showPhotosButton() {
        photoButtonWidthConstraint.isActive = true
        spaceBetweenButtonsConstraint.isActive = true
    }

    class func calculateCellHeight(_ tableWidth: CGFloat, room: HDKRoom, currency: HDKCurrency, duration: Int) -> CGFloat {
        let photosAndBookButtonsHeight: CGFloat = 40.0

        return super.calculateCellHeight(tableWidth, room: room, currency: currency) + photosAndBookButtonsHeight
    }
}
