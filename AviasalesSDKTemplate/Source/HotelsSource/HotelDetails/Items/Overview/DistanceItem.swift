class DistanceItem: TableItem {
    let poi: HDKLocationPoint
    let variant: HLResultVariant

    init(poi: HDKLocationPoint, variant: HLResultVariant) {
        self.poi = poi
        self.variant = variant
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return HLHotelDetailsImportantPoiCell.estimatedHeight(tableWidth, first:first, last: last)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsImportantPoiCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsImportantPoiCell
        c.setup(poi, variant: variant)
        c.first = first
        c.last = last

        return c
    }
}
