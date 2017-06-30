class GroupedTableSection {

    var title: String?
    var items: [Any] = []

    init(title: String?, items: [Any]) {
        self.title = title
        self.items = items
    }
}

class GroupedTableItem {
    var title: String
    var action: (() -> Void)?
    var icon: UIImage?

    init(title: String, action: (() -> Void)? = nil, icon: UIImage? = nil) {
        self.title = title
        self.action = action
        self.icon = icon
    }

    func createCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLGroupedTableCell.hl_reuseIdentifier(), for: indexPath) as! HLGroupedTableCell
        cell.setupWithItem(self)

        return cell
    }
}

class GroupedLoadingItem: GroupedTableItem {
    override func createCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JRAirportPickerCellWithInfo.hl_reuseIdentifier(), for: indexPath) as! JRAirportPickerCellWithInfo
        cell.startActivityIndicator()
        cell.selectionStyle = .none
        cell.updateBackgroundViews(forImagePath: indexPath, in: tableView)
        cell.locationInfoLabel.font = UIFont.systemFont(ofSize: 15)

        return cell
    }
}

class LocationRequestItem: GroupedTableItem {
    override func createCell(_ tableView: UITableView, indexPath: IndexPath) -> HLGroupedTableCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLUserLocationTableCell.hl_reuseIdentifier(), for: indexPath) as! HLUserLocationTableCell
        cell.setupWithItem(self)
        cell.setActive(HLNearbyCitiesDetector.shared().busy)

        return cell
    }
}
