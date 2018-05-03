@objcMembers
class PeekTableVC: HLCommonVC, UITableViewDataSource, UITableViewDelegate, PeekVCProtocol {

    var commitBlock: (() -> Void)?
    weak var viewControllerToShowBrowser: UIViewController?
    @IBOutlet weak var tableView: UITableView?
    var items: [PeekItem] = []

    var variant: HLResultVariant! {
        didSet {
            items = createItems()
            setDividers()
            if self.isViewLoaded {
                self.tableView?.reloadData()
            }
        }
    }

    var filter: Filter? {
        didSet {
            items = createItems()
            setDividers()
            if self.isViewLoaded {
                self.tableView?.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.allowsSelection = false
        tableView?.hl_registerNib(withName: PeekHotelRatingCell.hl_reuseIdentifier())
        tableView?.hl_registerNib(withName: PeekHotelPriceCell.hl_reuseIdentifier())
        tableView?.hl_registerNib(withName: PeekHotelMapCell.hl_reuseIdentifier())
        tableView?.hl_registerNib(withName: PeekPhotoCell.hl_reuseIdentifier())
    }

    internal func createItems() -> [PeekItem] {
        return []
    }

    private func setDividers() {
        for i in 0..<items.count {
            let item = items[i]
            item.shouldDrawSeparator = shouldAddSeparator(index: i)
        }
    }

    private func shouldAddSeparator(index: Int) -> Bool {
        if index >= items.count - 1 {
            return false
        }

        let item = items[index]
        if item is MapPeekItem || item is PhotoPeekItem || item is AccomodationPeekItem {
            return false
        }

        let nextItem = items[index + 1]
        if nextItem is MapPeekItem || nextItem is PhotoPeekItem {
            return false
        }

        return true
    }

    // MARK: - Public

    func heightForVariant(_ variant: HLResultVariant!, peekWidth: CGFloat) -> CGFloat {
        var heightToReturn: CGFloat = 0.0
        for item in items {
            heightToReturn += item.height(width: peekWidth, variant: variant)
        }

        return heightToReturn
    }

    // MARK: - UITableViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = item.cell(tableView: tableView)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]

        return item.height(width: tableView.frame.width, variant: variant)
    }

}
