import UIKit

@objcMembers
class HLFiltersVC: HLCommonVC, HLFilterDelegate, UITableViewDelegate, UITableViewDataSource, PointSelectionDelegate, ChooseSelectionDelegate, CancelableFilterViewDelegate {
    @IBOutlet private weak var applyButton: UIButton?
    @IBOutlet weak var tableView: UITableView!

    var originalFilter: Filter?
    var filter: Filter?
    var searchInfo: HLSearchInfo!

    private var sectionsFactory: FilterCellFactory!
    private var sections: [FilterSection] = []

    weak var delegate: FiltersVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        registerNibs()
        setupButtons()

        guard let filter = filter else { return }
        sectionsFactory = FilterCellFactory(filter: filter, searchInfo: searchInfo)
        sectionsFactory.controlDelegate = self
        sectionsFactory.pointSelectionDelegate = self
        sectionsFactory.chooseSelectionDelegate = iPad() ? delegate : self
        sectionsFactory.cancelableFilterViewDelegate = self

		filter.delegate = self
        reloadData()

        var bottom: CGFloat = 20.0
        if let applyButton = applyButton {
            bottom += applyButton.frame.size.height
        } else {
            if let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                bottom += tabBarVC.tabBar.frame.size.height
            }
        }
        tableView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottom, right: 0.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        filter?.delegate = self
        saveFilterState()

        updateDropButtonState()
        updateHotelsCountLabel()
    }

    // MARK: - Private methods

    func registerNibs() {
        guard let tableView = tableView else { return }
        tableView.hl_registerNib(withName: SelectionFilterCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: StarFilterCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: FilterItemsWithSelectionFilterCell.hl_reuseIdentifier())

        let nib = UINib(nibName: MultiAmenityFilterCell.hl_reuseIdentifier(), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: FilterCellIdentifiers.property)
        tableView.register(nib, forCellReuseIdentifier: FilterCellIdentifiers.foodPayment)
        tableView.register(nib, forCellReuseIdentifier: FilterCellIdentifiers.roomAmenities)
        tableView.register(nib, forCellReuseIdentifier: FilterCellIdentifiers.hotelAmenities)

        tableView.hl_registerNib(withName: HLNameFilterCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: HLRatingFilterCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: HLDistanceFilterCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: HLPriceFilterCell.hl_reuseIdentifier())
    }

    func reloadData() {
        sections = sectionsFactory.createSections()
        tableView?.reloadData()
    }

	private func setupButtons() {
        title = NSLS("HL_LOC_FILTER_TITLE_LABEL")
        applyButton?.backgroundColor = JRColorScheme.actionColor()
        applyButton?.setTitleColor(.white, for: .normal)
        applyButton?.setTitle(NSLS("HL_LOC_FILTER_APPLY_BUTTON"), for: .normal)

		updateHotelsCountLabel()
	}

	func updateHotelsCountLabel() {
	}

    func updateDropButtonState() {
    }

    private func saveFilterState() {
        originalFilter = filter?.copy() as? Filter
    }

    // MARK: - IBActions methods

	@IBAction private func dropFilters() {
		filter?.dropFilters()
        reloadData()
        updateDropButtonState()
	}

    @IBAction func saveAndExit() {
        saveFilterState()
        goBack()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sections[indexPath.section].cell(tableView, indexPath: indexPath)
        cell.accessibilityIdentifier = "FilterCell"

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(0.00001)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].heightForCell(tableView, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].headerHeight()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].headerView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        item.selectionBlock?()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - HLFilterDelegate

    func didFilterVariants() {
        reloadData()
        updateDropButtonState()
        updateHotelsCountLabel()
        delegate?.didFilterVariants()
    }

    // MARK: - PointSelectionDelegate

    func openPointSelectionScreen() {
        let selectionVC = PointSelectionVC(nibName: "ASTGroupedSearchVC", bundle: nil)
        selectionVC.searchInfo = searchInfo
        selectionVC.selectionDelegate = delegate
        if let filterLocation = filter?.distanceLocationPoint.location {
            selectionVC.initialCustomPointSelectionLocation = filterLocation
        }

        if iPad() {
            customPresent(selectionVC, animated: true)
        } else {
            navigationController?.pushViewController(selectionVC, animated: true)
        }
    }

    // MARK: - ChooseSelectionDelegate

    func showSelectionViewController(_ selectionVC: FilterSelectionVC) {
        navigationController?.pushViewController(selectionVC, animated: true)
    }

    // MARK: - CancelableFilterViewDelegate

    func cancelableFilterViewCellPressed(viewCell: CancelableFilterViewCell) {
        reloadData()
        updateDropButtonState()
    }
}

extension HLFiltersVC: FilterControlDelegate {

    func didChangeMinimalRating(_ rating: Int) {
        filter?.currentMinRating = rating
        filter?.filter()
    }

    func didChangeMaximumDistance(_ distance: CGFloat) {
        filter?.currentMaxDistance = distance
        filter?.filter()
    }

    func didUpdatePrice(_ minPrice: Float, maxPrice: Float) {
        filter?.filter()
    }
}

extension HLFiltersVC {
    func openNameFilterScreen() {
        let pickerVC = HLNameFilterVC(nibName:"ASTGroupedSearchVC", bundle: nil)
        pickerVC.searchInfo = searchInfo
        pickerVC.filter = filter

        if iPad() {
            customPresent(pickerVC, animated: true)
        } else {
            navigationController?.pushViewController(pickerVC, animated: true)
        }
    }

}
