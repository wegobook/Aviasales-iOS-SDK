import UIKit

class ReviewTextCell: UITableViewCell {
    private let reviewContentView = HotelDetailsReviewHighlightQuoteView()
    private static let topContentMargin: CGFloat = 5
    let separatorView = SeparatorView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        createSubviews()
        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubviews() {
        contentView.addSubview(reviewContentView)

        separatorView.attachToView(contentView, edge: .bottom, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        separatorView.isHidden = true
    }

    func createConstraints() {
        reviewContentView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: ReviewTextCell.topContentMargin, left: 15, bottom: 0, right: 15))
    }

    func configure(withText text: String) {
        reviewContentView.configureForQuote(text)
    }

    static func preferredHeight(forText text: String, width: CGFloat) -> CGFloat {
        return ReviewTextCell.topContentMargin + HotelDetailsReviewHighlightQuoteView.preferredHeight(text, width: width)
    }
}
