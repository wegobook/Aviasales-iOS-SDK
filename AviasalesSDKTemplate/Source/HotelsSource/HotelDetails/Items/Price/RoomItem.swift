class RoomItem: TableItem {
    var room: HDKRoom
    var duration: Int
    var currency: HDKCurrency
    var canHighlightPrivatePrice: Bool
    var shouldShowSeparator = false

    init(room: HDKRoom, currency: HDKCurrency, duration: Int, canHighlightPrivatePrice: Bool) {
        self.room = room
        self.currency = currency
        self.duration = duration
        self.canHighlightPrivatePrice = canHighlightPrivatePrice
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return HLHotelDetailsPriceTableCell.calculateCellHeight(tableWidth, room: room, currency: currency, last: last)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsPriceTableCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsPriceTableCell
        cell.last = last
        cell.layoutIfNeeded()
        cell.canHighlightPrivatePrice = canHighlightPrivatePrice
        cell.configure(for: room, currency: currency, duration: duration, shouldShowSeparator: shouldShowSeparator)

        return cell
    }
}
