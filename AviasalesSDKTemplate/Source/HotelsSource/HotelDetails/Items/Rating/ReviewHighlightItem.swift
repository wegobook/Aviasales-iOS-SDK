class ReviewHighlightsItem: NamedHotelDetailsItem {
    var reviewHighlight: HDKReviewHighlight

    init(name: String, reviewHighlight: HDKReviewHighlight) {
        self.reviewHighlight = reviewHighlight

        super.init(name: name)
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return HotelDetailsReviewHighlightCell.preferredHeight(reviewHighlight, cellWidth: tableWidth, first: first)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HotelDetailsReviewHighlightCell.hl_reuseIdentifier(), for: indexPath) as! HotelDetailsReviewHighlightCell
        cell.configureForModel(reviewHighlight, cellWidth: tableView.bounds.width)
        cell.cellSeparatorView.isHidden = true
        cell.first = first

        return cell
    }
}
