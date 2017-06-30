class GoodToKnowItem: NamedHotelDetailsItem {
    var score: Int = 0

    init(name: String, score: Int) {
        super.init(name: name)
        self.score = score
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return HLHotelDetailsUsefullInfoCell.estimatedHeight(tableWidth, text: name, first: first, last: last)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let usefullInfoCell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsUsefullInfoCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsUsefullInfoCell
        usefullInfoCell.labelText = name
        usefullInfoCell.score = score
        usefullInfoCell.first = first
        usefullInfoCell.last = last

        return usefullInfoCell
    }
}
