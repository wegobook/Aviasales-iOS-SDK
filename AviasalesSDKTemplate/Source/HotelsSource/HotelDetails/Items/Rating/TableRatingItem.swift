class TableRatingItem: TableItem {
    private let trustYou: HDKTrustyou
    private let shortItems: Bool
    private let shouldShowSeparator: Bool
    private let moreHandler: (() -> Void)?

    init(trustYou: HDKTrustyou, shortItems: Bool, moreHandler: (() -> Void)?, shouldShowSeparator: Bool) {
        self.trustYou = trustYou
        self.shortItems = shortItems
        self.shouldShowSeparator = shouldShowSeparator
        self.moreHandler = moreHandler
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsTableRatingCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsTableRatingCell
        cell.shortItems = shortItems
        cell.moreHandler = moreHandler
        cell.update(withTrustYou: trustYou, tableWidth: tableView.bounds.size.width - HLHotelDetailsTableRatingCell.kHorizontalMargin * 2)
        cell.shouldShowSeparator = shouldShowSeparator

        return cell
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        let width = tableWidth - HLHotelDetailsTableRatingCell.kHorizontalMargin * 2
        return HLHotelDetailsTableRatingCell.estimatedHeight(shortDetails: shortItems, trustyou: trustYou, width: width, shouldShowSeparator: shouldShowSeparator)
    }
}
