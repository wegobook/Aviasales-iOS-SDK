import UIKit

class FilterMultiAmenitiesItem: CustomFilterViewTableItem {

    var elements: [StringFilterItem]
    var cellIdentifier: String

    init(filter: Filter, elements: [StringFilterItem], cellIdentifier: String) {
        self.elements = elements
        self.cellIdentifier = cellIdentifier
        super.init(filter: filter)
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return MultiAmenityFilterCell.height(for: tableWidth, with: filter, amenityFilterItems: elements)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MultiAmenityFilterCell
        cell.tableWidth = tableView.bounds.width
        cell.selectionStyle = .none
        cell.configure(with: filter, and: elements)

        return cell
    }
}
