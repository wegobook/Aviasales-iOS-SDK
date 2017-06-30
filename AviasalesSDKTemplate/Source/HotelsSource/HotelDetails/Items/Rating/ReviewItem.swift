class ReviewItem: TableItem {
    let model: HDKReview
    weak var delegate: ReviewCellDelegate?

    init(model: HDKReview, delegate: ReviewCellDelegate? = nil) {
        self.model = model
        self.delegate = delegate
        super.init()
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return ReviewCell.preferredHeight()
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.hl_reuseIdentifier(), for: indexPath) as! ReviewCell
        cell.layoutIfNeeded()
        cell.configure(forReview: model, shouldHideSeparator: last)
        cell.delegate = delegate
        return cell
    }
}
