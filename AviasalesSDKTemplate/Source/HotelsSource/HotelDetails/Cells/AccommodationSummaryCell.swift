import UIKit

class AccommodationSummaryCell: UITableViewCell {
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var checkinDateLabel: UILabel!
    @IBOutlet weak var checkinTimeLabel: UILabel!
    @IBOutlet weak var checkoutDateLabel: UILabel!
    @IBOutlet weak var checkoutTimeLabel: UILabel!
    @IBOutlet weak var guestsLabel: UILabel!
    @IBOutlet weak var adultGuestsLabel: UILabel!
    @IBOutlet weak var childGuestsLabel: UILabel!
    @IBOutlet weak var durationContainerView: UIView!
    @IBOutlet weak var durationContainerHeight: NSLayoutConstraint!
    private var separatorView = SeparatorView()
    @IBOutlet weak var childIcon: UIImageView!

    private static let kDefaultHeight: CGFloat = 184.0
    private static let kDefaultDurationHeight: CGFloat = 97.0

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        separatorView.attachToView(durationContainerView, edge: .bottom, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
    }

    func configure(withVariant variant: HLResultVariant) {
        let kidsCount = variant.searchInfo.kidAgesArray.count
        childGuestsLabel.text = StringUtils.childGuestsDescription(withCount: kidsCount)
        childGuestsLabel.isHidden = kidsCount == 0
        childIcon.isHidden = kidsCount == 0

        let adultsCount = variant.searchInfo.adultsCount
        adultGuestsLabel.text = StringUtils.adultGuestsDescription(withCount: adultsCount)

        let guestsCount = kidsCount + adultsCount
        guestsLabel.text = StringUtils.guestsDescription(withGuestsCount: guestsCount)

        if var checkinDate = variant.searchInfo.checkInDate, var checkOutDate = variant.searchInfo.checkOutDate {
            durationContainerHeight.constant = AccommodationSummaryCell.kDefaultDurationHeight
            separatorView.isHidden = false

            checkinDate = DateUtil.setTimeFor(checkinDate, time: variant.hotel.checkInTime)!
            checkOutDate = DateUtil.setTimeFor(checkOutDate, time: variant.hotel.checkOutTime)!

            durationLabel.text = StringUtils.durationDescription(withDays: variant.searchInfo.durationInDays)

            checkinDateLabel.text = StringUtils.accommodationSummaryCheckInString(for: checkinDate, shortMonth: false)
            checkoutDateLabel.text = StringUtils.accommodationSummaryCheckOutString(for: checkOutDate, shortMonth: false)

            if checkinDateLabel.isTruncated() || checkoutDateLabel.isTruncated() {
                checkinDateLabel.text = StringUtils.accommodationSummaryCheckInString(for: checkinDate, shortMonth: true)
                checkoutDateLabel.text = StringUtils.accommodationSummaryCheckOutString(for: checkOutDate, shortMonth: true)
            }

            checkinTimeLabel.text = StringUtils.checkInTime(from: checkinDate)
            checkoutTimeLabel.text = StringUtils.checkOutTime(from: checkOutDate)
        } else {
            durationContainerHeight.constant = 0.0
            separatorView.isHidden = false
            checkinTimeLabel.text = NSLS("HL_HOTEL_DETAIL_INFORMATION_CHECKIN")
            checkoutTimeLabel.text = NSLS("HL_HOTEL_DETAIL_INFORMATION_CHECKOUT")
        }
    }

    class func preferredHeight(forVariant variant: HLResultVariant) -> CGFloat {
        if variant.searchInfo.checkInDate != nil && variant.searchInfo.checkOutDate != nil {
            return kDefaultHeight
        } else {
            return kDefaultHeight - kDefaultDurationHeight
        }
    }
}
