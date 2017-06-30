import Foundation

class ReviewTextsContainerView: HLAutolayoutView {

    let positiveContentView = ReviewContentView(style: .positive)
    let negativeContentView = ReviewContentView(style: .negative)
    let neutralContentView = ReviewContentView(style: .neutral)

    var visibleViews: [UIView] = []

    func configure(review: HDKReview) {

        self.removeAllSubviews()
        visibleViews = []

        if !review.textPlus.isEmpty {
            positiveContentView.configure(forText: review.textPlus)
            visibleViews.append(positiveContentView)
        }

        if !review.textMinus.isEmpty {
            negativeContentView.configure(forText: review.textMinus)
            visibleViews.append(negativeContentView)
        }

        if !review.text.isEmpty {
            neutralContentView.configure(forText: review.text)
            visibleViews.append(neutralContentView)
        }

        for view in visibleViews {
            addSubview(view)
        }
        updateReviewConstraints()
    }

    private func updateReviewConstraints() {
        let nsarray: NSArray = visibleViews as NSArray
        nsarray.autoDistributeViews(along: .vertical, alignedTo: .leading, withFixedSpacing: 15, insetSpacing: false, matchedSizes: false)

        for view in visibleViews {
            view.autoPinEdge(toSuperviewEdge: .leading)
            view.autoPinEdge(toSuperviewEdge: .trailing)
        }
    }
}
