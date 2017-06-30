import UIKit

class HLHotelDetailsTableRatingCell: HLHotelDetailsTableCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    private var items: [TableItem] = []
    var shortItems = false
    @IBOutlet weak var backgroundBottomConstraint: NSLayoutConstraint!

    static let kHorizontalMargin: CGFloat = 15

    var shouldShowSeparator = false {
        didSet {
            backgroundBottomConstraint.constant = HLHotelDetailsTableRatingCell.backgroundBottomMargin(shouldShowSeparator: shouldShowSeparator)
            separatorView.isHidden = !shouldShowSeparator
        }
    }

    private var trustYou: HDKTrustyou?

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.reloadData()
    }

    var moreHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.hl_registerNib(withName: HLHotelDetailsRatingSummaryCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: HLHotelDetailsRatingDetailsCell.hl_reuseIdentifier())

        separatorView.isHidden = true
    }

    func update(withTrustYou trustYou: HDKTrustyou, tableWidth: CGFloat) {
        self.trustYou = trustYou
        updateItems(tableWidth: tableWidth)
        tableView.reloadData()
    }

    class func estimatedHeight(shortDetails: Bool, trustyou: HDKTrustyou, width: CGFloat, shouldShowSeparator: Bool) -> CGFloat {
        let tableTopMargin: CGFloat = 10
        let tableBottomMargin: CGFloat = 15

        let items = createItems(shortDetails: shortDetails, trustyou: trustyou, moreHandler: nil, cellWidth: width)
        let tableHeight = items.reduce(0, { $0 + $1.cellHeight(tableWidth: width) })

        return tableTopMargin + tableHeight + tableBottomMargin + backgroundBottomMargin(shouldShowSeparator: shouldShowSeparator)
    }

    class func backgroundBottomMargin(shouldShowSeparator: Bool) -> CGFloat {
        return shouldShowSeparator ? 20.0 : 0.0
    }

    func updateItems(tableWidth: CGFloat) {
        items = HLHotelDetailsTableRatingCell.createItems(shortDetails: shortItems, trustyou: trustYou, moreHandler: moreHandler, cellWidth: tableWidth)
    }

    class func createItems(shortDetails: Bool, trustyou: HDKTrustyou?, moreHandler: (() -> Void)?, cellWidth: CGFloat) -> [TableItem] {
        guard let trustyou = trustyou, trustyou.score > 0 else { return [] }

        var items: [TableItem] = [RatingItem(name: "", trustYou: trustyou, score: trustyou.score)]

        let ratingDetailItems = createRatingDetails(shortDetails: shortDetails, trustyou: trustyou, moreHandler: moreHandler, cellWidth: cellWidth)
        items += ratingDetailItems

        return items
    }

    private class func createRatingDetails(shortDetails: Bool, trustyou: HDKTrustyou, moreHandler: (() -> Void)?, cellWidth: CGFloat) -> [TableItem] {
        if shortDetails {
            return HLHotelDetailsCommonCellFactory.createShortRatingDetails(withTrustYou: trustyou, moreHandler: moreHandler, cellWidth: cellWidth)
        } else {
            return HLHotelDetailsCommonCellFactory.createRatingDetailItemsWithTrustYouData(trustyou, cellWidth: cellWidth)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = items[indexPath.row].cell(tableView: tableView, indexPath: indexPath)
        cell.backgroundColor = UIColor.clear
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items[indexPath.row].cellHeight(tableWidth: tableView.bounds.width)
    }
}
