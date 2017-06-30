class HotelDetailsReviewHighlightCell: HLAutolayoutCell {

    var nameLabel: UILabel!
    var quotesContainerView: HotelDetailsQuotesContainerView!
    var cellSeparatorView: CellSeparatorView!
    var topConstraint: NSLayoutConstraint!

    var first: Bool = false {
        didSet {
            topConstraint.constant = first ? Consts.firstCellTopMargin : Consts.defaultTopMargin
        }
    }

    private struct Consts {
        static let leftAndRightMargin: CGFloat = 30
        static let titleAndQuotesSpacing: CGFloat = 12
        static let defaultTopMargin: CGFloat = 25
        static let firstCellTopMargin: CGFloat = 5
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    fileprivate func initialize() {
        createSubviews()
        selectionStyle = .none
        updateConstraintsIfNeeded()
    }

    fileprivate func createSubviews() {
        nameLabel = UILabel()
        nameLabel.font = HotelDetailsReviewHighlightCell.titleFont
        nameLabel.numberOfLines = 0
        contentView.addSubview(nameLabel)

        quotesContainerView = HotelDetailsQuotesContainerView()
        contentView.addSubview(quotesContainerView)

        cellSeparatorView = CellSeparatorView()
        contentView.addSubview(cellSeparatorView)
    }

    override func setupConstraints() {
        topConstraint = nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 15)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 15)
        quotesContainerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), excludingEdge: .top)
        quotesContainerView.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: Consts.titleAndQuotesSpacing)

        cellSeparatorView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), excludingEdge: .top)
        cellSeparatorView.autoSetDimension(.height, toSize: CellSeparatorView.preferredHeight())
    }

    func configureForModel(_ model: HDKReviewHighlight, cellWidth: CGFloat) {
        nameLabel.textColor = JRColorScheme.ratingColor(model.score)
        nameLabel.text = model.title

        quotesContainerView.configureForQuotes(model.quotes, width: cellWidth - Consts.leftAndRightMargin)
    }

    override func prepareForReuse() {
        quotesContainerView.prepareForReuse()
    }

    fileprivate class var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 15.0)
    }

    class func preferredHeight(_ model: HDKReviewHighlight, cellWidth: CGFloat, first: Bool) -> CGFloat {
        let titleHeight = model.title.hl_height(attributes: [NSFontAttributeName: HotelDetailsReviewHighlightCell.titleFont], width: cellWidth - Consts.leftAndRightMargin)
        let quotesHeight = HotelDetailsQuotesContainerView.preferredHeight(model.quotes, width: cellWidth - Consts.leftAndRightMargin)
        return titleHeight + CGFloat(quotesHeight) + Consts.titleAndQuotesSpacing + (first ? Consts.firstCellTopMargin : Consts.defaultTopMargin)
    }
}
