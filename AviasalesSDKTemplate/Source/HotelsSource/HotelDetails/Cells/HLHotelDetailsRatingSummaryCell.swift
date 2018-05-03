import UIKit

class HLHotelDetailsRatingSummaryCell: HLHotelDetailsTableCell {

    var trustyou: HDKTrustyou! {
        didSet {
            self.updateControl()
        }
    }

    @IBOutlet fileprivate weak var reviewsCountLabel: UILabel!
    @IBOutlet fileprivate weak var scoreLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!

    // MARK: - Class metods

    class var descriptionLabelFont: UIFont {
        return UIFont.systemFont(ofSize: 13.0)
    }

    // MARK: - Private methods

    fileprivate func updateControl() {
        let score = trustyou.score
        scoreLabel.text = StringUtils.shortRatingString(score)
        scoreLabel.textColor = JRColorScheme.ratingColor(score)

        reviewsCountLabel.text = StringUtils.reviewsCountDescription(with: trustyou.reviewsCount)

        if let description = trustyou.summaryDescription, description.count > 0 {
            let lastSymbol = description.last
            descriptionLabel.text = (lastSymbol != ".") ? description + "." : description
        } else {
            descriptionLabel.text = ""
        }
    }
}
