class ActivityItem: TableItem {

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return 70.0
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsActivityIndicatorTableCell.hl_reuseIdentifier())
        if let activityCell = cell as? HLHotelDetailsActivityIndicatorTableCell {
            activityCell.startAnimating()
            activityCell.backgroundColor = UIColor.clear
        }

        return cell ?? UITableViewCell()
    }

}
