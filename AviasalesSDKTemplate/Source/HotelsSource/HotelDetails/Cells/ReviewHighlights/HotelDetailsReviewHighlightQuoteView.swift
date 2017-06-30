import UIKit

class HotelDetailsReviewHighlightQuoteView: HLAutolayoutView {

    var imageView: UIImageView!
    var textLabel: UILabel!

    fileprivate struct Consts {
        static let imageWidth: CGFloat = 15
        static let imageHeight: CGFloat = 9
        static let imageAndTextSpacing: CGFloat = 15
    }

    override func initialize() {
        createSubviews()
    }

    func createSubviews() {
        imageView = UIImageView(image: UIImage(named: "reviewHighlightQuote"))
        addSubview(imageView)

        textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.font = HotelDetailsReviewHighlightQuoteView.textFont
        textLabel.textColor = JRColorScheme.darkTextColor()
        addSubview(textLabel)
    }

    override func setupConstraints() {
        imageView.autoPinEdge(toSuperviewEdge: .leading)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 4)
        imageView.autoSetDimensions(to: CGSize(width: Consts.imageWidth, height: Consts.imageHeight))

        textLabel.autoPinEdge(toSuperviewEdge: .top)
        textLabel.autoPinEdge(toSuperviewEdge: .trailing)
        textLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: Consts.imageAndTextSpacing)
        textLabel.autoPinEdge(toSuperviewEdge: .bottom)
    }

    func configureForQuote(_ quote: String) {
        textLabel.text = quote
    }

    class var textFont: UIFont {
        return UIFont.systemFont(ofSize: 15.0)
    }

    class func preferredHeight(_ quote: String, width: CGFloat) -> CGFloat {
        let leftMargin = Consts.imageWidth + Consts.imageAndTextSpacing
        return quote.hl_height(attributes: [NSFontAttributeName: HotelDetailsReviewHighlightQuoteView.textFont], width: width - leftMargin)
    }

    class func labelWidth(_ viewWidth: CGFloat) -> CGFloat {
        let leftMargin = Consts.imageWidth + Consts.imageAndTextSpacing
        return viewWidth - leftMargin
    }
}
