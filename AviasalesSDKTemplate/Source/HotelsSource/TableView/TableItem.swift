class TableItem: NSObject {
    var first: Bool = false
    var last: Bool = false
    var selectionBlock: (() -> Void)?

    func shouldHighlight() -> Bool {
        return true
    }

    var estimatedCellHeight: CGFloat {
        return 40
    }

    func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return 40.0
    }

    func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        assertionFailure("TableItem subclass has to override cell creation")
        return UITableViewCell()
    }

    static func setFirstAndLast(items: [TableItem]) {
        for i in 0..<items.count {
            let item = items[i]
            item.first = (i == 0)
            item.last = (i == items.count - 1)
        }
    }
}
