class ReviewTextItem: TableItem {
    let review: HDKReview

    init(review: HDKReview) {
        self.review = review
        super.init()
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        let kHorizontalMargin: CGFloat = 15
        return ReviewTextCell.preferredHeight(forText: reviewText(), width: tableWidth - kHorizontalMargin * 2) + (last ? 20 : 0.0)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTextCell.hl_reuseIdentifier(), for: indexPath) as! ReviewTextCell
        cell.configure(withText: reviewText())
        cell.separatorView.isHidden = !last
        return cell
    }

    private func reviewText() -> String {
        if !review.textPlus.isEmpty {
            return review.textPlus
        } else if !review.text.isEmpty {
            return review.text
        } else if !review.textMinus.isEmpty {
            return review.textMinus
        } else {
            return ""
        }
    }
}
