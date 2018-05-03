@objcMembers
class RatingView: UIView {

    let ratingLabel = UILabel()

    override func layoutSubviews() {
        super.layoutSubviews()

        let maskLayer = CAShapeLayer()
        let cornerSize = CGSize(width: 2.0, height: 2.0)
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: cornerSize).cgPath
        layer.mask = maskLayer
    }

    func setupWithHotel(_ hotel: HDKHotel) {
        clipsToBounds = true
        layer.cornerRadius = 1.0
        backgroundColor = JRColorScheme.ratingColor(hotel.rating)
        ratingLabel.textColor = UIColor.white
        ratingLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        ratingLabel.text = StringUtils.shortRatingString(hotel.rating)
        addSubview(ratingLabel)
        ratingLabel.autoCenterInSuperview()
    }
}
