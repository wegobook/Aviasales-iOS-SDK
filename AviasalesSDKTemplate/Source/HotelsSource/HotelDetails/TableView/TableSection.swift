class TableSection: TableSectionProtocol {
    var items: [TableItem] = []
    var name: String?

    init(name: String?, items: [TableItem]) {
        self.name = name
        self.items = items
    }

    func headerHeight() -> CGFloat {
        let hasTitle = !(name?.isEmpty ?? true)
        return HLGroupedTableHeaderView.preferredHeight(hasTitle)
    }

    func headerView() -> UIView {
        let sectionHeaderNib = UINib(nibName: headerNibName(), bundle: nil)
        let views = sectionHeaderNib.instantiate(withOwner: nil, options: nil) as! [UIView]
        let header = views.first! as! HLGroupedTableHeaderView
        header.title = name

        return header
    }

    func headerNibName() -> String {
        return "HLGroupedTableHeaderView"
    }

    func numberOfRows() -> Int {
        return items.count
    }

    func heightForCell(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]

        return item.cellHeight(tableWidth: tableView.bounds.width)
    }

    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]

        return item.cell(tableView: tableView, indexPath: indexPath)
    }
}
