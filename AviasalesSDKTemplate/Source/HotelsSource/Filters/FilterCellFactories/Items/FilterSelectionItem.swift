import UIKit

class FilterSelectionItem: TableItem {

    var title: String
    var active: Bool = false
    weak var cell: SelectionFilterCell?

    required init(title: String) {
        self.title = title
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return 44.0
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectionFilterCell.hl_reuseIdentifier(), for: indexPath) as! SelectionFilterCell
        cell.setup(self)

        return cell
    }

    func changeValue(for filter: Filter) {
    }

    func isActive(for filter: Filter) -> Bool {
        return active
    }
}

class DistrictFilterSelectionItem: FilterSelectionItem {
    override func changeValue(for filter: Filter) {
        if filter.districtsToFilter.contains(title) {
            filter.districtsToFilter.removeObject(title)
        } else {
            filter.districtsToFilter.append(title)
        }
    }

    override func isActive(for filter: Filter) -> Bool {
        return filter.districtsToFilter.contains(title)
    }
}

class GateFilterSelectionItem: FilterSelectionItem {
    override func changeValue(for filter: Filter) {
        if filter.gatesToFilter.contains(title) {
            filter.gatesToFilter.removeObject(title)
        } else {
            filter.gatesToFilter.append(title)
        }
    }

    override func isActive(for filter: Filter) -> Bool {
        return filter.gatesToFilter.contains(title)
    }
}
