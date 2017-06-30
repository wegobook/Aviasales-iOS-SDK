import UIKit

class HLRatingBadge: HLPopularHotelBadge {
    let ratingText: NSAttributedString

    init(rating: Int, isFull: Bool) {
        self.ratingText = StringUtils.ratingAttributedString(rating: rating, full: isFull)
        super.init()

        self.name = StringUtils.shortRatingString(rating)
        self.systemName = StringUtils.shortRatingString(rating)
        self.color = JRColorScheme.ratingColor(rating)
    }

}
