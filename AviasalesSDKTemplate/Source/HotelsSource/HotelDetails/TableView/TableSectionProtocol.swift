protocol TableSectionProtocol {
    func headerHeight() -> CGFloat
    func headerView() -> UIView
    func numberOfRows() -> Int
    func heightForCell(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
}
