class PoweredByBookingCell: UITableViewCell {

    let poweredByImageView: UIImageView = UIImageView()
    let verifiedImageView: UIImageView = UIImageView()
    let titleLabel: UILabel = UILabel()
    let subtitleLabel: UILabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {
        poweredByImageView.image = UIImage(named: "poweredByBooking")
        contentView.addSubview(poweredByImageView)

        verifiedImageView.image = UIImage(named: "bookingRealReviewsLogo")
        contentView.addSubview(verifiedImageView)

        titleLabel.font = UIFont.systemFont(ofSize: 13.0)
        titleLabel.textColor = JRColorScheme.darkBackgroundColor()
        titleLabel.text = NSLS("HL_REVIEWS_POWERED_BY_BOOKING_TITLE")
        contentView.addSubview(titleLabel)

        subtitleLabel.font = UIFont.systemFont(ofSize: 11.0)
        subtitleLabel.textColor = JRColorScheme.lightBackgroundColor()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = NSLS("HL_REVIEWS_POWERED_BY_BOOKING_SUBTITLE")

        contentView.addSubview(subtitleLabel)
    }

    private func createConstraints() {
        verifiedImageView.autoSetDimensions(to: CGSize(width: 27, height: 30))
        verifiedImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 15)
        verifiedImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 15)

        titleLabel.autoPinEdge(.top, to: .top, of: verifiedImageView)
        titleLabel.autoPinEdge(.leading, to: .trailing, of: verifiedImageView, withOffset: 5)
        poweredByImageView.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 10, relation: .greaterThanOrEqual)

        subtitleLabel.autoPinEdge(.leading, to: .leading, of: titleLabel)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 2)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 15)

        poweredByImageView.autoPinEdge(.leading, to: .trailing, of: subtitleLabel, withOffset: 10, relation: .equal)

        poweredByImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 15)
        poweredByImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15)
        poweredByImageView.autoSetDimensions(to: CGSize(width: 87, height: 30))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if subtitleLabel.preferredMaxLayoutWidth != subtitleLabel.frame.width {
            subtitleLabel.preferredMaxLayoutWidth = subtitleLabel.frame.width
            super.layoutSubviews()
        }
    }

}
