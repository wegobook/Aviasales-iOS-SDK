class MapItem: TableItem {

    var variant: HLResultVariant
    var filter: Filter?

    init(variant: HLResultVariant, filter: Filter?) {
        self.variant = variant
        self.filter = filter
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return HLHotelDetailsMapCell.estimatedHeight(variant.hotel, width: tableWidth)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let mapCell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsMapCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsMapCell
        mapCell.layoutIfNeeded()
        mapCell.variant = variant
        mapCell.filter = filter
        mapCell.setMapRegion()

        return mapCell
    }
}
