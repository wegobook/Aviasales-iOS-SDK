import UIKit

class AccommodationSummaryItem: TableItem {
    private let variant: HLResultVariant

    init(variant: HLResultVariant) {
        self.variant = variant
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return AccommodationSummaryCell.preferredHeight(forVariant: variant)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccommodationSummaryCell.hl_reuseIdentifier()) as! AccommodationSummaryCell
        cell.configure(withVariant: variant)

        return cell
    }
}
