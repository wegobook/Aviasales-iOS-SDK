import UIKit

class CancelableFilterItem: CustomFilterViewTableItem, DummyCancelableFilterViewCellDelegate {

    weak var delegate: ChooseSelectionDelegate?
    weak var cancelableDelegate: CancelableFilterViewDelegate?

    var filterAllItemType: FilterSelectionItem.Type {
        return FilterSelectionItem.self
    }

    var filterCancelableItemType: StringFilterItem.Type {
        return StringFilterItem.self
    }

    var selectionViewControllerTitle: String {
        return ""
    }

    var chooseButtonTitle: String {
        return ""
    }

    var dummyItemTitle: String {
        return ""
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return FilterItemsWithSelectionFilterCell.height(for: tableWidth, with: filter, stringFilterItems: cancellableOrDummyItems(for: filter))
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterItemsWithSelectionFilterCell.hl_reuseIdentifier(), for: indexPath) as! FilterItemsWithSelectionFilterCell
        cell.chooseButtonPressedAction = { [weak self] in
            self?.chooseButtonPressed()
        }
        cell.tableWidth = tableView.bounds.width
        cell.selectionStyle = .none
        cell.chooseButton.setTitle(self.chooseButtonTitle, for: .normal)
        cell.configure(with: filter, and: cancellableOrDummyItems(for: filter))
        cell.cancelableFilterView.dummyDelegate = self
        cell.cancelableFilterView.cancelableDelegate = cancelableDelegate

        return cell
    }

    func dummyCancelableFilterViewCellPressed(dummyViewCell: CancelableFilterViewCell) {
        chooseButtonPressed()
    }

    func chooseButtonPressed() {
        let filter = self.filter
        let selectionVC = FilterSelectionVC(nibName: "FilterSelectionVC", bundle: nil)
        let sortedItems = self.allItems(for: filter)
        let filterAllItemType = self.filterAllItemType
        let title = self.selectionViewControllerTitle

        let items: [[FilterSelectionItem]] = sortedItems.map { $0.map({ (itemTitle) -> FilterSelectionItem in
                let item = filterAllItemType.init(title: itemTitle)
                item.selectionBlock = self.selectionBlock(for: item, and: filter)
                item.active = item.isActive(for: filter)

                return item
            })
        }
        selectionVC.configure(with: items, title: title, and: filter)
        delegate?.showSelectionViewController(selectionVC)
    }

    func selectionBlock(for item: FilterSelectionItem, and filter: Filter) -> (() -> Void) {
        return { [weak item] in
            guard let item = item else { return }
            item.changeValue(for: filter)
            filter.filter()

            item.active = item.isActive(for: filter)
            item.cell?.active = item.active
        }
    }

    func allItems(for filter: Filter) -> [[String]] {
        return []
    }

    func cancelableItems(for filter: Filter) -> [StringFilterItem] {
        return []
    }

    func cancellableOrDummyItems(for filter: Filter) -> [StringFilterItem] {
        let cancelableItems = self.cancelableItems(for: filter)
        let allItemsCount = self.allItems(for: filter).flatMap({ $0 }).count

        if cancelableItems.count > 0 && cancelableItems.count < allItemsCount {
            return cancelableItems
        } else {
            return [DummyFilterItem(filterString: dummyItemTitle, text: dummyItemTitle)]
        }
    }
}

class FilterDistrictsItem: CancelableFilterItem {

    override var filterAllItemType: FilterSelectionItem.Type {
        return DistrictFilterSelectionItem.self
    }

    override var filterCancelableItemType: StringFilterItem.Type {
        return DistrictFilterItem.self
    }

    override var chooseButtonTitle: String {
        return NSLS("HL_LOC_FILTER_SELECT_DISTRICTS")
    }

    override var selectionViewControllerTitle: String {
        return NSLS("HL_LOC_FILTER_DISTRICTS_SELECTION")
    }

    override var dummyItemTitle: String {
        return NSLS("HL_LOC_FILTER_ALL_DISTRICTS")
    }

    override func allItems(for filter: Filter) -> [[String]] {
        return [filter.searchResult.allDistrictsNames.sorted(by: {$0 < $1})]
    }

    override func cancelableItems(for filter: Filter) -> [StringFilterItem] {
        return filter.districtsToFilter.sorted(by: {$0 < $1}).map { DistrictFilterItem(filterString: $0, text: $0) }
    }
}

class FilterGatesItem: CancelableFilterItem {

    override var filterAllItemType: FilterSelectionItem.Type {
        return GateFilterSelectionItem.self
    }

    override var filterCancelableItemType: StringFilterItem.Type {
        return GateFilterItem.self
    }

    override var chooseButtonTitle: String {
        return NSLS("HL_LOC_FILTER_SELECT_GATES")
    }

    override var selectionViewControllerTitle: String {
        return NSLS("HL_LOC_FILTER_GATES_SELECTION")
    }

    override var dummyItemTitle: String {
        return NSLS("HL_LOC_FILTER_ALL_GATES")
    }

    override func allItems(for filter: Filter) -> [[String]] {
        var allGatesNames = filter.searchResult.allGatesNames.sorted(by: {$0 < $1})
        let hotelWebsiteAgencyName = FilterLogic.hotelWebsiteAgencyName()
        if allGatesNames.contains(hotelWebsiteAgencyName) {
            allGatesNames.removeObject(hotelWebsiteAgencyName)

            return [allGatesNames, [hotelWebsiteAgencyName]]
        }

        return [allGatesNames]
    }

    override func cancelableItems(for filter: Filter) -> [StringFilterItem] {
        return filter.gatesToFilter.sorted(by: {$0 < $1}).map { GateFilterItem(filterString: $0, text: $0) }
    }
}
