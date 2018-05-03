class HLIpadHotelDetailsVC: HLHotelDetailsVC {

    @IBOutlet private weak var bottomHotelInfoConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightPhotoConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightCollectionConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leftCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftTableViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var verticalSeparatorView: UIView!
    @IBOutlet private weak var photosContainer: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet private weak var verticalSeparatorViewWidth: NSLayoutConstraint!

    private var targetConfiguration = HotelDetailsTargetConfiguration()
    private var landscapePhotosTab: HLHotelDetailPhotosTabCell?
    private var needLayoutControl: Bool = true
    private let kTabBarHeight: CGFloat = 44

    override var photoIndex: Int {
        didSet {
            landscapePhotosTab?.setSelectedStyleForPhotoIndex(photoIndex)
        }
    }

    static fileprivate let minPortraitHotelInfoHeight: CGFloat = 461.0
    static fileprivate let contentCollectionViewLandsapeWidth: CGFloat = 375.0
    static fileprivate let contentCollectionViewPortraitHeight: CGFloat = 350.0
    static fileprivate let horizontalMarginPortrait: CGFloat = 130.0
    static fileprivate let portraitHotelInfoHeight: CGFloat = max(minPortraitHotelInfoHeight, minScreenDimension() - contentCollectionViewPortraitHeight)
    static fileprivate let portraitHotelInfoBottomMargin: CGFloat = maxScreenDimension() - portraitHotelInfoHeight
    static fileprivate let landscapeHotelInfoBottomMargin: CGFloat = contentCollectionViewPortraitHeight
    static fileprivate let photoMarginLandscape: CGFloat = contentCollectionViewLandsapeWidth
    static fileprivate let infoMarginLandscape: CGFloat = maxScreenDimension() - contentCollectionViewLandsapeWidth
    static fileprivate let defaultFooterHeight: CGFloat = 15.0

    fileprivate var orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation

    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.layoutIfNeeded()
        contentTableView.hl_setScrollableArea(to: contentContainerView)

        var insets = contentTableView.contentInset
        insets.bottom += kTabBarHeight
        contentTableView.contentInset = insets

        updateHotelViewGradients()

        hotelView.hideInfoControls = true
        hotelView.bottomGradientView.isHidden = true
        hotelView.selectPhotoHandler = { [weak self] (index: Int) -> Void in
            self?.showPhotosScreen()
        }

        verticalSeparatorViewWidth.constant = UIView.onePixel
        updateVerticalSeparatorViewVisibility()

        createPhotosGrid()
        decoratorDelegate?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setNeedsLayoutControls()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        layoutControlsIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let landscapePhotosTab = landscapePhotosTab else { return }
        if landscapePhotosTab.hotel == nil && landscapePhotosTab.bounds.width > 0 {
            landscapePhotosTab.hotel = variant.hotel
        }
    }

    func createPhotosGrid() {
        updatePhotosContainerVisibility()

        landscapePhotosTab = HLHotelDetailPhotosTabCell()
        landscapePhotosTab!.delegate = self
        landscapePhotosTab!.setSelectedStyleForPhotoIndex(photoIndex)
        landscapePhotosTab!.photoGrid.currentPhotoIndex = photoIndex

        photosContainer.addSubview(landscapePhotosTab!)
        landscapePhotosTab?.autoPinEdgesToSuperviewEdges()
    }

    func updateHotelViewGradients() {
        if orientation.isLandscape {
            hotelView.hideGradients(animated: false)
        } else {
            hotelView.showGradients(animated: false)
        }
    }

    func updateVerticalSeparatorViewVisibility() {
        verticalSeparatorView.isHidden = orientation.isPortrait
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        orientation = (size.width < size.height) ? UIInterfaceOrientation.portrait : UIInterfaceOrientation.landscapeLeft

        updateTableViewTopInset()
        updateVerticalSeparatorViewVisibility()
        setNeedsLayoutControls()

        updateHotelViewGradients()
        contentTableView.reloadData()

        landscapePhotosTab?.alpha = 0.0
        coordinator.animate(alongsideTransition: { (context) -> Void in
            var frame = self.view.frame
            frame.size = size
            self.view.frame = frame

            self.landscapePhotosTab?.alpha = 1.0

            }, completion: { cell in self.contentTableView.reloadData() })
    }

    // MARK: - Override

    func layoutControls() {
        updateConstraints()
        updatePhotosContainerVisibility()
    }

    override func hotelDetailsDidLoad(_ hotel: HDKHotel) {
        super.hotelDetailsDidLoad(hotel)
        landscapePhotosTab?.hotel = hotel
    }

    override func shouldShowPhotoButton() -> Bool {
        return orientation.isPortrait
    }

    // MARK: - Private methods

    func setNeedsLayoutControls() {
        needLayoutControl = true
    }

    func layoutControlsIfNeeded() {
        if needLayoutControl {
            layoutControls()
            needLayoutControl = false
        }
    }

    fileprivate func updatePhotosContainerVisibility() {
        photosContainer.isHidden = orientation.isPortrait
    }

    fileprivate func updateConstraints() {
        if orientation.isPortrait {
            bottomHotelInfoConstraint.constant = HLIpadHotelDetailsVC.portraitHotelInfoBottomMargin
            rightCollectionConstraint.constant = 0.0
            leftCollectionConstraint.constant = 0.0
            rightPhotoConstraint.constant = 0.0
            rightTableViewConstraint.constant = HLIpadHotelDetailsVC.horizontalMarginPortrait
            leftTableViewConstraint.constant = HLIpadHotelDetailsVC.horizontalMarginPortrait
        } else {
            bottomHotelInfoConstraint.constant = HLIpadHotelDetailsVC.landscapeHotelInfoBottomMargin
            rightCollectionConstraint.constant = 0.0
            leftCollectionConstraint.constant = HLIpadHotelDetailsVC.infoMarginLandscape
            rightPhotoConstraint.constant = HLIpadHotelDetailsVC.photoMarginLandscape
            rightTableViewConstraint.constant = 0.0
            leftTableViewConstraint.constant = 0.0
        }

        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()

        hotelView.setNeedsLayout()
        hotelView.layoutIfNeeded()
    }

    private func updateTableViewTopInset() {
        contentTableView.contentInset.top = topContentInset()
    }

}

// MARK: - HLHotelDetailsTabCellDelegate methods

extension HLIpadHotelDetailsVC {

    override func topContentInset() -> CGFloat {
        return orientation.isPortrait ? HLIpadHotelDetailsVC.portraitHotelInfoHeight - kTabBarHeight : 0.0
    }

    func footerHeightForContentSize(_ contentSize: CGSize) -> CGFloat {
        return HLIpadHotelDetailsVC.defaultFooterHeight
    }

    override func showPhotoAtIndex(_ index: Int) {
        super.showPhotoAtIndex(index)

        hotelView.currentPhotoIndex = index
        photoIndex = index
    }

    override func photosColumnsCount() -> Int {
        return orientation.isPortrait ? 4 : 5
    }

    func photoGridViewCellDidSelect(_ cell: HLPhotoScrollCollectionCell) {
        cell.applySelectedStyle(cell.isSelected)
    }

}
