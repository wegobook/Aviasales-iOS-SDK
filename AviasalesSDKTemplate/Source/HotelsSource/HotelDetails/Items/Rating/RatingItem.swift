class RatingItem: NamedHotelDetailsItem {
    var trustYou: HDKTrustyou
    var score: Int

    init(name: String, trustYou: HDKTrustyou, score: Int) {
        self.score = score
        self.trustYou = trustYou
        super.init(name: name)
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        let minHeight: CGFloat = 50

        if let description = trustYou.summaryDescription {
            let leftDescriptionMargin: CGFloat = 103
            let rightDescriptionMargin: CGFloat = 15
            let topDescriptionMargin: CGFloat = 24
            let bottomDescriptionMargin: CGFloat = 2
            let descriptionWidth = tableWidth - leftDescriptionMargin - rightDescriptionMargin

            let descriptionHeight = description.hl_height(attributes: [NSFontAttributeName: HLHotelDetailsRatingSummaryCell.descriptionLabelFont], width: descriptionWidth)

            return max(topDescriptionMargin + descriptionHeight + bottomDescriptionMargin, minHeight)
        } else {
            return minHeight
        }
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsRatingSummaryCell.hl_reuseIdentifier(), for: indexPath)  as! HLHotelDetailsRatingSummaryCell
        cell.trustyou = trustYou

        return cell
    }
}
