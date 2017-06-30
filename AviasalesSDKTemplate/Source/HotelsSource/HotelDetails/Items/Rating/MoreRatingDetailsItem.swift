import UIKit

class MoreRatingDetailsItem: NamedHotelDetailsItem {
    let moreHandler: (() -> Void)?

    init(moreCount: Int, moreHandler: (() -> Void)?) {
        self.moreHandler = moreHandler
        let name = String(format: NSLS("HL_HOTEL_DETAIL_RATING_DETAILS_MORE"), moreCount)
        super.init(name: name)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsRatingDetailsCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsRatingDetailsCell
        cell.configureForMoreItem(self, columnCellStyle: .oneColumn)
        cell.first = first
        cell.last = last

        return cell
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return HLHotelDetailsRatingDetailsCell.estimatedHeight(first, last: last)
    }
}
