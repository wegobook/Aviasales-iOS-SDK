class TripTypeItem: NamedHotelDetailsItem {
    var image: UIImage = UIImage()
    let percentage: Int
    let tripType: TripTypes

    init(name: String, image: UIImage, percentage: Int, tripType: TripTypes) {
        self.percentage = percentage
        self.tripType = tripType
        super.init(name: name)
        self.image = image
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return HLHotelDetailsFeaturesCell.estimatedHeight(first, last: last)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsFeaturesCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsFeaturesCell
        cell.configureForTripTypeItem(self)
        cell.first = first
        cell.last = last

        return cell
    }
}
