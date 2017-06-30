import UIKit

class FilterPriceItem: FilterSliderItem {

    var currency: HDKCurrency

    init(filter: Filter, controlDelegate: FilterControlDelegate?, currency: HDKCurrency) {
        self.currency = currency
        super.init(filter: filter, controlDelegate: controlDelegate)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLPriceFilterCell.hl_reuseIdentifier(), for: indexPath) as! HLPriceFilterCell
        cell.currency = currency
        cell.filter = filter
        cell.setSliderThumbs()
        cell.filterControlDelegate = controlDelegate
        cell.selectionStyle = .none

        return cell
    }
}
