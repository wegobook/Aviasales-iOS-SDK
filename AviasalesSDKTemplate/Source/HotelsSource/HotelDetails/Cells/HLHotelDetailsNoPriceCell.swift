fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class HLHotelDetailsNoPriceCell: HLHotelDetailsTableCell {
    @IBOutlet fileprivate weak var noPriceLabel: UILabel!
    @IBOutlet fileprivate(set) weak var changeButton: UIButton!
    private static let textFont = UIFont.systemFont(ofSize: 15.0)

    var noPriceReasonText: String = "" {
        didSet {
            noPriceLabel.text = noPriceReasonText
        }
    }
    var changeHandler: (() -> Void)!

    class func estimatedHeight(_ text: String?, width: CGFloat, canChangeSearchInfo: Bool) -> CGFloat {
        guard canChangeSearchInfo || !text.isNilOrEmpty()  else {
            return 0.0
        }

        let topMargin: CGFloat = 5.0
        var textHeight: CGFloat = 0.0
        if text?.characters.count > 0 {
            let horizontalMargin: CGFloat = 15.0
            textHeight = text!.hl_height(attributes: [NSFontAttributeName: HLHotelDetailsNoPriceCell.textFont], width: width - 2 * horizontalMargin)
        }

        let spaceBetweenButtonAndText: CGFloat = 15.0
        let buttonHeight: CGFloat = canChangeSearchInfo ? 40.0 : 0.0
        let bottomMargin: CGFloat = 20.0

        return topMargin + textHeight + spaceBetweenButtonAndText + buttonHeight + bottomMargin
    }

    @IBAction func changeButtonPressed(_ sender: AnyObject) {
        changeHandler()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        noPriceReasonText = ""
        noPriceLabel.font = HLHotelDetailsNoPriceCell.textFont
        changeButton.backgroundColor = JRColorScheme.mainButtonBackgroundColor()
    }
}
