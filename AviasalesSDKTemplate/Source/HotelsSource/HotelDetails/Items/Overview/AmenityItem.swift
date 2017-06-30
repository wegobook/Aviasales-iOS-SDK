class AmenityItem: NamedHotelDetailsItem {
    var image: UIImage

    init(name: String, image: UIImage) {
        self.image = image
        super.init(name: name)
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return HLHotelDetailsFeaturesCell.estimatedHeight(first, last: last)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let amenityCell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsFeaturesCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsFeaturesCell
        amenityCell.configureForAmenity(self)
        amenityCell.first = first
        amenityCell.last = last

        return amenityCell
    }
}
