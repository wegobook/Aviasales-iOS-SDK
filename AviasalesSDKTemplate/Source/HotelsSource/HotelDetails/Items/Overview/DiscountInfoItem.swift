class DiscountInfoItem: TableItem {
    private let searchInfo: HLSearchInfo
    private let room: HDKRoom

    init(room: HDKRoom, searchInfo: HLSearchInfo) {
        self.room = room
        self.searchInfo = searchInfo
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        let duration = DateUtil.hl_daysBetweenDate(searchInfo.checkInDate, andOtherDate: searchInfo.checkOutDate)

        return DiscountCell.preferredHeight(width: tableWidth, room: room, currency: searchInfo.currency, duration: duration)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiscountCell.hl_reuseIdentifier(), for: indexPath) as! DiscountCell
        let currency = searchInfo.currency
        let duration = DateUtil.hl_daysBetweenDate(searchInfo.checkInDate, andOtherDate: searchInfo.checkOutDate)
        cell.last = last
        cell.configure(for: room, currency: currency, duration: duration)

        return cell
    }
}
