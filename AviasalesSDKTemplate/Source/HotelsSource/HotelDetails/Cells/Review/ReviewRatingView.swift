import Foundation

class ReviewRatingView: HLAutolayoutView {

    let starImageView = UIImageView()
    let ratingValueLabel = UILabel()
    private var rating: Int?

    override func initialize() {
        setupSubviews()
    }

    func setupSubviews() {
        starImageView.image = UIImage(named: "reviewRatingStar")
        addSubview(starImageView)

        ratingValueLabel.textColor = UIColor.white
        ratingValueLabel.font = UIFont.systemFont(ofSize: 15.0)
        ratingValueLabel.textAlignment = .center
        addSubview(ratingValueLabel)
    }

    override func setupConstraints() {
        starImageView.autoSetDimensions(to: CGSize(width: 12, height: 12))
        starImageView.autoCenterInSuperview()

        ratingValueLabel.autoPinEdgesToSuperviewEdges()
    }

    func configure(forRating rating: Int?) {
        self.rating = rating

        if let rating = rating {
            ratingValueLabel.text = StringUtils.shortRatingString(rating)
            ratingValueLabel.isHidden = false
            starImageView.isHidden = true
            backgroundColor = JRColorScheme.ratingColor(rating)
        } else {
            ratingValueLabel.text = ""
            ratingValueLabel.isHidden = true
            starImageView.isHidden = false
            backgroundColor = UIColor(red: 207.0/255.0, green: 216.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        }
    }
}
