class RatingDetailItem: RatingItem {

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return HLHotelDetailsRatingDetailsCell.estimatedHeight(first, last: last)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsRatingDetailsCell.hl_reuseIdentifier(), for: indexPath)  as! HLHotelDetailsRatingDetailsCell
        cell.configureForRatingDetails(self)
        cell.first = first
        cell.last = last

        return cell
    }
}
