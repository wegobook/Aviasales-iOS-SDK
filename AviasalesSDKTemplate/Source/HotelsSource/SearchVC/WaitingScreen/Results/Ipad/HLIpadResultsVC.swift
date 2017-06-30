import UIKit

class HLIpadResultsVC: HLCommonResultsVC {

    static let filtersViewWidth: CGFloat = 320.0
    fileprivate let filtersAppearanceDuration: TimeInterval = 0.5
    fileprivate let portraitContentWidth: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    fileprivate let landscapeContentWidth: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - HLIpadResultsVC.filtersViewWidth

    var filtersVC: HLFiltersVC!

    @IBOutlet weak fileprivate var filtersContainer: UIView!
    @IBOutlet weak fileprivate var portraitFiltersShadeView: UIView!
    @IBOutlet fileprivate var sortLabel: UILabel!
    @IBOutlet fileprivate var filtersContainerToSuperviewTrailing: NSLayoutConstraint!
    @IBOutlet fileprivate var contentToFiltersHorizontalSpacing: NSLayoutConstraint!
    @IBOutlet fileprivate var filtersContainerWidth: NSLayoutConstraint!
    @IBOutlet fileprivate var contentContainerWidth: NSLayoutConstraint!
    @IBOutlet fileprivate var sortButtonEdgeConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var sortButtonToFilterConstraint: NSLayoutConstraint!

    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()

        sortLabel.text = NSLS("HL_LOC_SORT_HEADER_TITLE")
        updateSortButtonTitle()

        addFilterClosingGestureRecognizers()

        filtersVC = createFiltersVC()
        filtersVC.delegate = self
        filter.delegate = filtersVC

        addChildViewController(filtersVC, to: filtersContainer)
        filtersVC.view.autoPinEdgesToSuperviewEdges()

        filtersContainerWidth.constant = HLIpadResultsVC.filtersViewWidth
        setInitialFiltersStateForOrientation(UIApplication.shared.statusBarOrientation)
        sortButton.setTitleColor(JRColorScheme.mainButtonBackgroundColor(), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setInitialFiltersStateForOrientation(UIApplication.shared.statusBarOrientation)
        filtersVC.filter = filter
        filtersVC.reloadData()
        didFilterVariants()
    }

    override func createMapVC() -> HLMapVC {
        return HLIpadMapVC(nibName: "HLIpadMapVC", bundle: nil)
    }

    override func showFilters(animated: Bool) {
        openFiltersScreen(UIApplication.shared.statusBarOrientation)
    }

    override func presentSortVC(_ sortVC: HLSortVC, animated: Bool) {
        super.presentSortVC(sortVC, animated: animated)

        sortVC.view.backgroundColor = UIColor.clear
        presentPopover(sortVC, under: sortButton, distance: 0.0, contentSize: CGSize(width: 420.0, height: sortVC.contentHeight()), backgroundColor: UIColor.white, cornerRadius: 20)
        sortVC.delegate = self
    }

    override func sortDidApply() {
        super.sortDidApply()

        dismiss(animated: true, completion: nil)
        updateSortButtonTitle()
    }

    override func didFilterVariants() {
        super.didFilterVariants()

        updateSortButtonTitle()
    }

    override func setFiltersButtonSelected(_ selected: Bool) {
        super.setFiltersButtonSelected(selected)
        if selected {
            setButtonContentOffsets(filtersButton!)
        } else {
            filtersButton.imageEdgeInsets = UIEdgeInsets.zero
            filtersButton.titleEdgeInsets = UIEdgeInsets.zero
            filtersButton.contentEdgeInsets = UIEdgeInsets.zero
        }
    }

    // MARK: - Private

    fileprivate func addFilterClosingGestureRecognizers() {
        let selector = #selector(HLIpadResultsVC.dismissFilters)
        let tapRec = UITapGestureRecognizer(target: self, action: selector)
        portraitFiltersShadeView.addGestureRecognizer(tapRec)
        let leftSwipeRec = UISwipeGestureRecognizer(target: self, action: selector)
        leftSwipeRec.direction = .left
        portraitFiltersShadeView.addGestureRecognizer(leftSwipeRec)
        let rightSwipeRec = UISwipeGestureRecognizer(target: self, action: selector)
        rightSwipeRec.direction = .right
        portraitFiltersShadeView.addGestureRecognizer(rightSwipeRec)
    }

    private func setButtonContentOffsets(_ button: UIButton) {
        let insetAmount: CGFloat = 5.0
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }

    // MARK: - HLFiltersContainerDelegate Methods

    func setInitialFiltersStateForOrientation(_ orientation: UIInterfaceOrientation) {
        let fullScreenFiltersMode = areFiltersInFullscreenMode(orientation)
        filtersContainerToSuperviewTrailing.isActive = fullScreenFiltersMode
        contentToFiltersHorizontalSpacing.isActive = true
//        sortButtonEdgeConstraint.isActive = fullScreenFiltersMode
//        sortButtonToFilterConstraint.isActive = !fullScreenFiltersMode

        contentContainerWidth.constant = fullScreenFiltersMode ? landscapeContentWidth : portraitContentWidth
        if fullScreenFiltersMode && filter.allVariants.count == 0 {
            contentContainerWidth.constant += HLIpadResultsVC.filtersViewWidth
            filtersContainer.isHidden = true
        }
        portraitFiltersShadeView.alpha = 0.0
        filtersButton.alpha = fullScreenFiltersMode ? 0.0 : 1.0
    }

    func openFiltersScreen(_ orientation: UIInterfaceOrientation) {
        if orientation.isPortrait {
            portraitFiltersShadeView.alpha = 0.0
            portraitFiltersShadeView.isHidden = false

            view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: filtersAppearanceDuration, animations: {
                self.filtersContainerToSuperviewTrailing.isActive = true
                self.contentToFiltersHorizontalSpacing.isActive = false
                self.portraitFiltersShadeView.alpha = 1.0
                self.view.layoutIfNeeded()
            })
        }
    }

    // MARK: - HLFiltersDismissDelegate Methods

    func dismissFilters() {
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: filtersAppearanceDuration, animations: {
            self.setInitialFiltersStateForOrientation(UIApplication.shared.statusBarOrientation)
            self.view.layoutIfNeeded()
            }, completion: { (finished) in
                self.portraitFiltersShadeView.isHidden = true
        })
    }

    // MARK: - HLPlaceholderViewDelegate Methods

    override func dropFilters() {
        super.dropFilters()

        filtersVC.reloadData()
    }

    func moveToNewSearch() {
        _ = navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - ChooseSelectionDelegate

    override func showSelectionViewController(_ selectionVC: FilterSelectionVC) {
        customPresent(selectionVC, animated: true)
    }

    // MARK: - Private Methods

    fileprivate func updateSortButtonTitle() {
        var sortName = VariantsSorter.localizedNameForSortType(filter.sortType)
        if filter.sortType == .distance {
            if let distanceLocation = filter.distanceLocationPoint?.name {
                sortName += " " + distanceLocation
            }
        }
        sortButton?.setTitle(sortName, for: UIControlState())
    }

    fileprivate func areFiltersInFullscreenMode(_ orientation: UIInterfaceOrientation) -> Bool {
        return orientation.isLandscape
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let orientation = (size.width < size.height) ? UIInterfaceOrientation.portrait : UIInterfaceOrientation.landscapeLeft
        view.setNeedsUpdateConstraints()

        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.setInitialFiltersStateForOrientation(orientation)
            self.view.layoutIfNeeded()
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                self.portraitFiltersShadeView.isHidden = true
        })
    }

}
