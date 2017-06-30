class PeekItem: NSObject {
    var shouldDrawSeparator: Bool = false
    var variant: HLResultVariant

    init(_ variant: HLResultVariant) {
        self.variant = variant
    }

    func height(width: CGFloat, variant: HLResultVariant) -> CGFloat {
        return 44.0
    }

    func cell(tableView: UITableView) -> UITableViewCell {
        return UITableViewCell()
    }
}

class MapPeekItem: PeekItem {

    var filter: Filter?

    init(_ variant: HLResultVariant, filter: Filter?) {
        self.filter = filter
        super.init(variant)
    }

    override func height(width: CGFloat, variant: HLResultVariant?) -> CGFloat {
        return 240.0
    }

    override func cell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PeekHotelMapCell.hl_reuseIdentifier()) as! PeekHotelMapCell
        cell.configure(self)

        return cell
    }
}

class RatingPeekItem: PeekItem {
    override func height(width: CGFloat, variant: HLResultVariant) -> CGFloat {
        return 65.0
    }

    override func cell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PeekHotelRatingCell.hl_reuseIdentifier()) as! PeekHotelRatingCell
        cell.configure(self)

        return cell
    }
}

class PhotoPeekItem: PeekItem {
    var photoIndex: Int = 0

    override func height(width: CGFloat, variant: HLResultVariant) -> CGFloat {
        return HLPhotoManager.defaultHotelPhotoSize.height
    }

    override func cell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PeekPhotoCell.hl_reuseIdentifier()) as! PeekPhotoCell
        cell.configure(self)

        return cell
    }
}

class PricePeekItem: PeekItem {

    var room: HDKRoom?

    init(_ variant: HLResultVariant, room: HDKRoom?) {
        super.init(variant)
        self.room = room
    }

    override init(_ variant: HLResultVariant) {
        self.room = variant.roomWithMinPrice
        super.init(variant)
    }

    override func height(width: CGFloat, variant: HLResultVariant) -> CGFloat {
        return HLPriceTableViewCell.calculateCellHeight(width, room:room!, currency: variant.searchInfo.currency)
    }

    override func cell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PeekHotelPriceCell.hl_reuseIdentifier()) as! PeekHotelPriceCell
        cell.configure(self)

        return cell
    }
}

class FullInfoItem: PeekItem {
    override func height(width: CGFloat, variant: HLResultVariant) -> CGFloat {
        return 110.0
    }

    override func cell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PeekFullInfoCell.hl_reuseIdentifier()) as! PeekFullInfoCell
        cell.configure(self)

        return cell
    }
}

class AccomodationPeekItem: PeekItem {
    var infoItem: AccommodationItem?

    override func height(width: CGFloat, variant: HLResultVariant) -> CGFloat {
        guard let infoItem = infoItem else { return 44 }
        return AccommodationCell.preferredHeight(infoItem.first, isLast: infoItem.last)
    }

    override func cell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccommodationCell.hl_reuseIdentifier()) as! AccommodationCell
        guard let infoItem = self.infoItem else { return cell }
        cell.configure(item: infoItem)

        return cell
    }
}
