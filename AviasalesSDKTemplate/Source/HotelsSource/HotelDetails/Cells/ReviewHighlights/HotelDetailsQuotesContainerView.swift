import UIKit

class HotelDetailsQuotesContainerView: HLAutolayoutView {

    private var quotesViews = [HotelDetailsReviewHighlightQuoteView]()

    private struct Consts {
        static let quotesVerticalSpacing: CGFloat = 10
    }

    func configureForQuotes(_ quotes: [String], width: CGFloat) {
        quotesViews = createQuoteViews(quotes, width: width)
        setupConstraintsForQuotesViews()
    }

    private func createQuoteViews(_ quotes: [String], width: CGFloat) -> [HotelDetailsReviewHighlightQuoteView] {
        guard quotes.count > 0 else { return [] }

        var quoteViews: [HotelDetailsReviewHighlightQuoteView] = []

        for quote in quotes {
            createQuoteView(quote, quoteViews: &quoteViews)
        }

        return quoteViews
    }

    private func setupConstraintsForQuotesViews() {
        guard quotesViews.count > 0 else { return }

        (quotesViews as NSArray).autoDistributeViews(along: .vertical, alignedTo: .leading, withFixedSpacing: Consts.quotesVerticalSpacing, insetSpacing: false, matchedSizes: false)

        for quoteView in quotesViews {
            quoteView.autoPinEdge(toSuperviewEdge: .leading)
            quoteView.autoPinEdge(toSuperviewEdge: .trailing)
        }
    }

    private func createQuoteView(_ quote: String, quoteViews: inout [HotelDetailsReviewHighlightQuoteView]) {
        let view = HotelDetailsReviewHighlightQuoteView()
        view.configureForQuote(quote)
        addSubview(view)
        quoteViews.append(view)
    }

    func prepareForReuse() {
        for view in quotesViews {
            view.removeFromSuperview()
        }
        quotesViews = []
    }

    class func preferredHeight(_ quotes: [String], width: CGFloat) -> CGFloat {
        guard quotes.count > 0 else { return 0 }

        var result: CGFloat = 0
        for quote in quotes {
            result += HotelDetailsReviewHighlightQuoteView.preferredHeight(quote, width: width)
        }
        let innerSpacing = Consts.quotesVerticalSpacing * CGFloat(quotes.count - 1)
        result += innerSpacing
        return result
    }

}
