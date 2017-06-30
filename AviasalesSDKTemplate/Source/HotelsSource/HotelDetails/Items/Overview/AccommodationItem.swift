class AccommodationItem: TableItem {
    let text: String
    let name: String
    var shouldHighlightText: Bool = false

    init(name: String, text: String) {
        self.text = text
        self.name = name
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return AccommodationCell.preferredHeight(first, isLast: last)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: AccommodationCell.hl_reuseIdentifier()) as! AccommodationCell
        c.configure(item: self)

        return c
    }
}
