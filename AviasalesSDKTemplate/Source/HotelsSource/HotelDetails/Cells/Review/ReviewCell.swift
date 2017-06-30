import Foundation

@objc protocol ReviewCellDelegate: class {
    func gateLogoClicked(review: HDKReview)
}

class ReviewCell: UITableViewCell {

    private struct Consts {
        static let gateLogoWidth: CGFloat = 100
        static let gateLogoHeight: CGFloat = 15
    }

    let ratingView = ReviewRatingView()
    let authorLabel = UILabel()
    let dateLabel = UILabel()
    let gateLogo = GateLogoView()
    let separatorView = SeparatorView()

    var review: HDKReview?

    let reviewTextsView = ReviewTextsContainerView()

    weak var delegate: ReviewCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        createConstraints()
        addEventHandlers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {
        contentView.addSubview(ratingView)

        authorLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        authorLabel.textColor = JRColorScheme.darkTextColor()
        contentView.addSubview(authorLabel)

        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        dateLabel.textColor = JRColorScheme.darkTextColor()
        contentView.addSubview(dateLabel)
        contentView.addSubview(gateLogo)
        contentView.addSubview(reviewTextsView)

        separatorView.attachToView(contentView, edge: .bottom, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
    }

    private func createConstraints() {
        let ratingViewSize: CGFloat = 30
        ratingView.autoSetDimensions(to: CGSize(width: ratingViewSize, height: ratingViewSize))
        ratingView.autoPinEdge(toSuperviewEdge: .leading, withInset: 15)
        ratingView.autoPinEdge(.top, to: .top, of: authorLabel, withOffset: 1)
        ratingView.layer.cornerRadius = ratingViewSize / 2.0

        authorLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        authorLabel.autoPinEdge(.top, to: .top, of: ratingView, withOffset: -1)
        authorLabel.autoPinEdge(.leading, to: .trailing, of: ratingView, withOffset: 7)
        authorLabel.autoPinEdge(.trailing, to: .leading, of: gateLogo)

        dateLabel.autoPinEdge(.leading, to: .leading, of: authorLabel)
        dateLabel.autoPinEdge(.top, to: .bottom, of: authorLabel)

        gateLogo.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15)
        gateLogo.autoAlignAxis(.horizontal, toSameAxisOf: ratingView)

        gateLogo.autoSetDimensions(to: CGSize(width: Consts.gateLogoWidth, height: Consts.gateLogoHeight))

        reviewTextsView.autoPinEdge(toSuperviewEdge: .leading, withInset: 15)
        reviewTextsView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15)
        reviewTextsView.autoPinEdge(.top, to: .bottom, of: dateLabel, withOffset: 15)

        NSLayoutConstraint.autoSetPriority(900) {
            self.reviewTextsView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        }
    }

    func configure(forReview review: HDKReview, shouldHideSeparator: Bool) {
        self.review = review

        authorLabel.text = review.author
        dateLabel.text = StringUtils.reviewDate(date: review.createdAt)
        ratingView.configure(forRating: review.rating)
        gateLogo.configure(forGate: review.gate, maxImageSize: CGSize(width: Consts.gateLogoWidth, height: Consts.gateLogoHeight), alignment: .right)
        reviewTextsView.configure(review: review)

        separatorView.isHidden = shouldHideSeparator
    }

    func gateLogoClicked() {
        guard let review = review else { return }
        delegate?.gateLogoClicked(review: review)
    }

    private func addEventHandlers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(gateLogoClicked))
        gateLogo.isUserInteractionEnabled = true
        gateLogo.addGestureRecognizer(tap)
    }

    static func preferredHeight() -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
