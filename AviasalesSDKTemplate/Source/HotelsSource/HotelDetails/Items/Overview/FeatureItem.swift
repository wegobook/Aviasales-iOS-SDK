class FeatureItem: NamedHotelDetailsItem {

    var descriptionString: String?
    let image: UIImage
    var badges: [HLPopularHotelBadge] = []

    init(name: String, image: UIImage, badges: [HLPopularHotelBadge] = [], descriptionString: String? = nil) {
        self.image = image
        super.init(name:name)
        self.badges = badges
        self.descriptionString = descriptionString
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        if self.badges.count > 0 {
            return HLHotelDetailsBadgesCell.estimatedHeight(badges, width: tableWidth, first: first, last: last)
        } else {
            let hasDescription = descriptionString?.count ?? 0 > 0
            return HLHotelDetailsFeaturesCell.estimatedHeight(first, last: last, hasDescription: hasDescription)
        }
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return HLHotelDetailsCommonCellFactory.featureCell(self, tableView: tableView, indexPath: indexPath, first: first, last: last)
    }
}
