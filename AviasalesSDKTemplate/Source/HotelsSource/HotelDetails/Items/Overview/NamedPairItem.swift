class NamedPairItem: TableItem {
    var firstItem: NamedHotelDetailsItem
    var secondItem: NamedHotelDetailsItem?

    init(firstItem: NamedHotelDetailsItem, secondItem: NamedHotelDetailsItem?) {
        self.firstItem = firstItem
        self.secondItem = secondItem
        super.init()
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        firstItem.first = first
        firstItem.last = last

        if let secondItem = secondItem {
            secondItem.first = first
            secondItem.last = last

            return max(firstItem.cellHeight(tableWidth: tableWidth), secondItem.cellHeight(tableWidth: tableWidth))
        }

        return firstItem.cellHeight(tableWidth: tableWidth)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if let firstAmenity = firstItem as? AmenityItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsFeaturesCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsFeaturesCell
            cell.configureForAmenityPair(firstAmenity, secondAmenity: (secondItem as? AmenityItem))
            cell.first = first
            cell.last = last

            return cell
        }

        if let firstRating = firstItem as? RatingDetailItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsRatingDetailsCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsRatingDetailsCell
            cell.configureForRatingDetailsPair(firstRating, secondItem: (secondItem as? RatingDetailItem))
            if let moreItem = secondItem as? MoreRatingDetailsItem {
                cell.configureForMoreItem(moreItem, columnCellStyle: .twoColumns)
            }
            cell.first = first
            cell.last = last

            return cell
        }

        if let firstTripTypeItem = firstItem as? TripTypeItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsFeaturesCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsFeaturesCell
            cell.configureForTripTypeItemPair(firstTripTypeItem, secondTripType: (secondItem as? TripTypeItem))
            cell.first = first
            cell.last = last

            return cell
        }

        return UITableViewCell()
    }
}
