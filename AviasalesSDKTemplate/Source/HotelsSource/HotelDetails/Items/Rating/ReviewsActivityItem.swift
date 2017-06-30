class ReviewsActivityItem: TableItem {
    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return 78.0
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let activityCell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsActivityIndicatorTableCell.hl_reuseIdentifier()) as! HLHotelDetailsActivityIndicatorTableCell
        activityCell.startAnimating()
        activityCell.backgroundColor = UIColor.white

        return activityCell
    }
}
