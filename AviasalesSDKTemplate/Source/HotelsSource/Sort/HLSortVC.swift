struct SortItem {
    let name: String
    let sortType: SortType
    var cellReuseIdentifier: String = HLSortCell.hl_reuseIdentifier()

    init(name: String, sortType: SortType) {
        self.name = name
        self.sortType = sortType
    }
}

class HLSortVC: HLCommonVC, UITableViewDataSource, UITableViewDelegate, PointSelectionDelegate {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: (HLFilterDelegate & PointSelectionDelegate)?
    weak var filterControlDelegate: FilterControlDelegate?

    var filter: Filter!
    var searchInfo: HLSearchInfo!

    var ascending: Bool = false
    var sortType: SortType!
    var sortDidApply: (() -> Void)?
    let rowHeight: CGFloat = 64.0
    let defaultMargin: CGFloat = 8.0

    lazy var items: [SortItem] = {

        let itemsFactory = HotellookSortItemsFactory()
        let sortTypes = itemsFactory.sortTypesForFilter(self.filter)

        return sortTypes.map({ (sortType) -> SortItem in
            var item = SortItem(name: VariantsSorter.localizedNameForSortType(sortType), sortType: sortType)
            if sortType == SortType.distance {
                item.cellReuseIdentifier = HLDistanceSortCell.hl_reuseIdentifier()
            }
            return item
        })
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLS("HL_LOC_SORT_HEADER_TITLE")
        tableView.hl_registerNib(withName: HLSortCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: HLDistanceSortCell.hl_reuseIdentifier())
        sortType = filter.sortType
        tableView.tableHeaderView = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func contentHeight() -> CGFloat {
        let rowsHeight = CGFloat(items.count) * rowHeight
        return ceil(rowsHeight + (iPhone() ? defaultMargin : 0.0))
    }

    private func deactivateCellsInSection(_ section: Int) {
        for i in 0 ..< self.tableView(tableView, numberOfRowsInSection: section) {
            if let cell: SelectionFilterCell = tableView.cellForRow(at: IndexPath(item: i, section: section)) as? SelectionFilterCell {
                cell.active = false
            }
        }
    }

    // MARK: - UICollectionViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellReuseIdentifier, for: indexPath)
        if let sortCell = cell as? HLSortCell {
            sortCell.titleLabel.text = item.name
            sortCell.backgroundColor = UIColor.clear
            sortCell.active = (item.sortType.rawValue == filter.sortType.rawValue)
        }
        if let distanceCell = cell as? HLDistanceSortCell {
            distanceCell.pointButton.setTitle(filter.distanceLocationPoint.name, for: .normal)
            distanceCell.pointSelectionDelegate = self
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(ZERO_HEADER_HEIGHT)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(ZERO_HEADER_HEIGHT)
    }

    // MARK: - UICollectionViewDelegate methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deactivateCellsInSection(indexPath.section)

        let cell = tableView.cellForRow(at: indexPath) as! SelectionFilterCell
        cell.active = true

        if indexPath.section == 0 {
            sortType = items[indexPath.row].sortType
        }
        filter?.sortType = sortType
        filter?.filter()
        sortDidApply?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HLSortVC {

    func locationPointSelected(_ point: HDKLocationPoint) {
        filter.sortType = .distance
        if !point.isEqual(filter.distanceLocationPoint) {
            filter.distanceLocationPoint = point
            filter.filter()
            tableView.reloadData()
        }
        sortDidApply?()

        if iPad() {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    func requestUserLocation() {
        HLLocationManager.shared().requestUserLocation(withLocationDestination: nil)
    }

    func openPointSelectionScreen() {
        let selectionVC = PointSelectionVC(nibName: "ASTGroupedSearchVC", bundle: nil)
        selectionVC.searchInfo = searchInfo
        selectionVC.selectionDelegate = self
        if let filterLocation = filter?.distanceLocationPoint.location {
            selectionVC.initialCustomPointSelectionLocation = filterLocation
        }

        if iPad() {
            customPresent(selectionVC, animated: true)
        } else {
            navigationController?.pushViewController(selectionVC, animated: true)
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
