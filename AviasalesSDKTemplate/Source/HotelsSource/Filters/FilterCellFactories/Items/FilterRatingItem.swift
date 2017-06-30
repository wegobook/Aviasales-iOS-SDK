import UIKit

class FilterRatingItem: FilterSliderItem {

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLRatingFilterCell.hl_reuseIdentifier(), for: indexPath) as! HLRatingFilterCell
        cell.filterControlDelegate = controlDelegate
        cell.currentRating = Int(filter.currentMinRating)
        cell.selectionStyle = .none

        return cell
    }
}
