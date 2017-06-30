class ExpandPriceItem: TableItem {
    var shouldShowSeparator = true
    var section: PriceSection

    init(section: PriceSection) {
        self.section = section
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLShowMorePricesCell.hl_reuseIdentifier(), for: indexPath) as! HLShowMorePricesCell
        cell.setShouldShowSeparator(shouldShowSeparator)
        if section.expanded {
            cell.titleLabel?.text = NSLS("HL_HOTEL_DETAIL_HIDE_ROOMS")
        } else {
            let additionalRooms = section.rooms.count - section.kCollapsedCount
            let additionalString = String(format: NSLS("HL_HOTEL_DETAIL_SHOW_MORE_ROOMS"), String(additionalRooms))
            cell.titleLabel?.text = additionalString
        }
        return cell

    }
}
