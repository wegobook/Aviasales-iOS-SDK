class ReviewsErrorItem: TableItem {
    var buttonHandler: (() -> Void)?

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let errorCell = tableView.dequeueReusableCell(withIdentifier: ReviewsErrorCell.hl_reuseIdentifier(), for: indexPath) as! ReviewsErrorCell
        errorCell.buttonHandler = buttonHandler
        return errorCell
    }
}
