class FilterNameItem: TableItem, NameFilterDelegate {

    var filter: Filter

    init(_ filter: Filter) {
        self.filter = filter
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return 44.0
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLNameFilterCell.hl_reuseIdentifier(), for: indexPath) as! HLNameFilterCell
        let keyString = filter.keyString ?? ""
        cell.setTitle(keyString)
        cell.delegate = self

        return cell
    }

    // MARK: - NameFilterDelegate

    func dropNameFilter() {
        filter.keyString = ""
        filter.filter()
    }
}
