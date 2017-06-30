import UIKit
import Messages
import PromiseKit
import HotellookSDK
import MessageUI
import SafariServices

typealias PhotoIndexUpdaterBlock = (_ index: Int) -> Void

enum HotelDetailsTabState: Int {
    case none = 0
    case loading
    case completed
    case failed
    case noPrices
    case searchInfoSelectionNeeded
}

enum ReviewsTabState {
    case unknown
    case loading
    case loaded
    case failed
}

class HLHotelDetailsCollectionView: UICollectionView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var viewToReturn: UIView? = nil
        if !self.visibleCellsContainPoint(point) {
            if let cell = self.visibleCells.first as? HLHotelDetailsTabCell {
                viewToReturn = cell.hlScrollView
            }
        }

        return viewToReturn ?? super.hitTest(point, with: event)
    }

    func visibleCellsContainPoint(_ point: CGPoint) -> Bool {
        var cellsContainPoint = false
        for visibleCell in self.visibleCells {
            if visibleCell.frame.contains(point) {
                cellsContainPoint = true
                break
            }
        }

        return cellsContainPoint
    }
}

@objc class HLHotelDetailsVC: HLCommonVC,
    UITableViewDelegate,
    UITableViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UIActionSheetDelegate,
    HLHotelsManagerDelegate,
    MFMessageComposeViewControllerDelegate,
    ReviewsVCDelegate {

    private let kMaxReviewsLimit = 300

    @IBOutlet fileprivate(set) weak var contentTableView: UITableView!
    @IBOutlet fileprivate(set) weak var hotelView: HLHotelCardView!

    fileprivate(set) var detailState: HotelDetailsTabState = .none {
        didSet {
            createSections()
            contentTableView.reloadData()
        }
    }
    fileprivate(set) var reviewsState: ReviewsTabState = .unknown {
        didSet {
            createSections()
            contentTableView.reloadData()
        }
    }

    private var urlShortener: HLUrlShortener = HLUrlShortener()
    private var progressView: HLSpinnerProgressView?
    var sections: [TableSection] = []

    var locationSection: TableSection?
    var ratingSection: TableSection?
    var reviewsSection: TableSection?
    var bestPriceSection: TableSection?

    weak var decoratorDelegate: HLHotelDetailsDecoratorProtocol?
    var filter: Filter?
    var visiblePhotoIndexUpdater: PhotoIndexUpdaterBlock?
    var photoIndex: Int = 0

    var variant: HLResultVariant! {
        didSet {
            self.updatePriceInfoState(newState: pricesInfoState)
            self.setupContent()
        }
    }

    var pricesInfoState: HotelDetailsTabState = .completed {
        didSet {
            guard isViewLoaded else { return }
            createSections()
            contentTableView.reloadData()
        }
    }

    private let hotelsManager = HLHotelsManager()

    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()

        addNameAndStarsView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(HLHotelDetailsVC.share))

        configureContentCollectionView()
        registerCells()
        createSections()

        hotelView.photoIndexChangeHandler = { [weak self] (index: Int) -> Void in
            self?.photoIndex = index
        }
    }

    private func addNameAndStarsView() {
        let navBarView = HotelDetailsNavBarView(variant: variant)
        let limits = CGSize(width: 375.0, height: 35.0)
        let size = navBarView.systemLayoutSizeFitting(limits)
        navBarView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        navigationItem.titleView = navBarView
    }

    func configureContentCollectionView() {
        contentTableView.contentInset.top = topContentInset()
    }

    func registerCells() {
        contentTableView.hl_registerNib(withName: HLHotelDetailsActivityIndicatorTableCell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: HLHotelDetailsErrorTableCell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: HLHotelDetailsMapCell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: HLHotelDetailsFeaturesCell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: HLHotelDetailsBadgesCell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: HLHotelDetailsPriceCTACell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: HLHotelDetailsNoPriceCell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: HLHotelDetailsImportantPoiCell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: HLHotelDetailsTableRatingCell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: AccommodationSummaryCell.hl_reuseIdentifier())
        contentTableView.register(ReviewTextCell.self, forCellReuseIdentifier: ReviewTextCell.hl_reuseIdentifier())
        contentTableView.register(DiscountCell.self, forCellReuseIdentifier: DiscountCell.hl_reuseIdentifier())
        contentTableView.register(AccommodationCell.self, forCellReuseIdentifier: AccommodationCell.hl_reuseIdentifier())
        contentTableView.register(MultipleLinesFeatureCell.self, forCellReuseIdentifier: MultipleLinesFeatureCell.hl_reuseIdentifier())
        contentTableView.register(ReviewsErrorCell.self, forCellReuseIdentifier: ReviewsErrorCell.hl_reuseIdentifier())
        contentTableView.hl_registerNib(withName: ExpandCell.hl_reuseIdentifier())
    }

    func createSections() {
        switch detailState {
        case .loading:
            bestPriceSection = createBestPriceSection(variant)
            self.sections = [bestPriceSection!, createLocationSection(variant, filter: filter), createActivitySection()]
        case .failed:
            bestPriceSection = createBestPriceSection(variant)
            self.sections = [bestPriceSection!, createLocationSection(variant, filter: filter), createErrorSection()]
        default:
            self.sections = createCompletedStateSections()
        }
    }

    private func createCompletedStateSections() -> [TableSection] {

        guard let variant = self.variant else { return [] }

        var sections: [TableSection] = []

        bestPriceSection = createBestPriceSection(variant)
        sections.append(bestPriceSection!)

        let newLocationSection = createLocationSection(variant, filter: filter)
        sections.append(newLocationSection)
        locationSection = newLocationSection

        if let ratingSection = createRatingSection() {
            sections.append(ratingSection)
            self.ratingSection = ratingSection
        }

        if let reviewsSection = createReviewsSection(variant: variant) {
            sections.append(reviewsSection)
            self.reviewsSection = reviewsSection
        }

        let hotel = variant.hotel

        let features = HLHotelDetailsCommonCellFactory.features(variant, badges: variant.popularBadges)
        if features.count > 0 {
            TableItem.setFirstAndLast(items: features)
            sections.append(TableSection(name: NSLS("HL_HOTEL_DETAIL_INFORMATION_ABOUT_SECTION"), items: features))
        }

        let amenitiesInRoom = HLHotelDetailsAmenityCellFactory.createAmenitiesInRoom(hotel, tableView: contentTableView)
        if amenitiesInRoom.count > 0 {
            TableItem.setFirstAndLast(items: amenitiesInRoom)
            sections.append(TableSection(name: NSLS("HL_HOTEL_DETAIL_INFORMATION_AMENITIES_IN_ROOM_SECTION"), items: amenitiesInRoom))
        }

        let amenitiesInHotel = HLHotelDetailsAmenityCellFactory.createAmenitiesInHotel(hotel, tableView: contentTableView)
        if amenitiesInHotel.count > 0 {
            TableItem.setFirstAndLast(items: amenitiesInHotel)
            sections.append(TableSection(name: NSLS("HL_HOTEL_DETAIL_INFORMATION_AMENITIES_IN_HOTEL_SECTION"), items: amenitiesInHotel))
        }

        if let accomodationSection = createAccommodationSummarySection() {
            sections.append(accomodationSection)
        }

        return sections
    }

    private func createBestPriceSection(_ variant: HLResultVariant) -> TableSection {
        var items = [TableItem]()
        let name = topHeaderTitle()
        let bestPriceItem = BestPriceItem(variant: variant, priceInfoState: pricesInfoState)
        bestPriceItem.shouldShowPhotoButton = shouldShowPhotoButton()
        bestPriceItem.bookHandler = { [weak self] in self?.bookRoom(variant.roomWithMinPrice!) }
        bestPriceItem.photoHandler = { [weak self] in self?.showPhotosScreen() }
        bestPriceItem.changeParamsHandler = { [weak self] in self?.navigationController?.popToRootViewController(animated: true) }
        items.append(bestPriceItem)

        if let room = variant.roomWithMinPrice, room.hasDiscountHighlight() {
            items.append(DiscountInfoItem(room:room, searchInfo: variant.searchInfo))
        }

        if pricesInfoState == .completed {
            let expandItem = ExpandItem()
            expandItem.selectionBlock = {[weak self] in self?.showPricesScreen() }
            expandItem.title = NSLS("HL_HOTEL_DETAIL_ALL_PRICES_TITLE")
            expandItem.height = 60
            expandItem.shouldShowArrow = true
            items.append(expandItem)
        }

        TableItem.setFirstAndLast(items: items)

        return TableSection(name: name, items: items)
    }

    func shouldShowPhotoButton() -> Bool {
        return true
    }

    private func topHeaderTitle() -> String {
        if pricesInfoState == .noPrices {
            return NSLS("HL_HOTEL_DETAIL_NO_ROOMS_TITLE")
        } else {
            let duration = StringUtils.durationDescription(withDays: variant.duration)

            return NSLS("HL_HOTEL_DETAIL_CTA_HEADER_TITLE") + duration
        }
    }

    private func createLocationSection(_ variant: HLResultVariant, filter: Filter?) -> TableSection {
        var poiItems: [TableItem] = []
        let points: [HDKLocationPoint] = HLPoiManager.selectHotelDetailsPoints(variant, filter: filter)
        for i in 0..<points.count {
            let poi = points[i]
            let item = DistanceItem(poi: poi, variant: variant)
            item.selectionBlock = { [weak self] in self?.showDistancePoints() }
            poiItems.append(item)
        }

        let mapItem = MapItem(variant: variant, filter: filter)
        let items = [mapItem] + poiItems
        TableItem.setFirstAndLast(items: items)

        return LocationSection(name: NSLS("HL_HOTEL_DETAIL_INFORMATION_LOCATION_SECTION"), items: items)
    }

    private func createRatingSection() -> TableSection? {
        guard let trustyou = variant?.hotel.trustyou,
            trustyou.score > 0 else { return nil }

        let moreHandler: () -> Void = { [weak self] in self?.showRatingVC() }
        var items: [TableItem] = [TableRatingItem(trustYou: trustyou, shortItems: true, moreHandler: moreHandler, shouldShowSeparator: false)]

        let expandItem = ExpandItem()
        expandItem.selectionBlock = { [weak self] in self?.showRatingVC() }
        expandItem.title = NSLS("HL_HOTEL_DETAIL_FULL_RATING")
        expandItem.shouldShowArrow = true
        expandItem.height = 60
        items.append(expandItem)
        TableItem.setFirstAndLast(items: items)

        return TableSection(name: NSLS("HL_HOTEL_DETAIL_HEADER_TITLE_RATING_RECOMMENDATIONS"), items: items)
    }

    private func createAccommodationSummarySection() -> TableSection? {
        guard let variant = variant else { return nil }

        return TableSection(name: NSLS("HL_HOTEL_DETAIL_INFORMATION_ACCOMMODATION_SECTION"), items: [AccommodationSummaryItem(variant: variant)])
    }

      private func createReviewsSection(variant: HLResultVariant) -> TableSection? {
        guard variant.hotel.reviewsCount > 0 else { return nil }

        switch reviewsState {
        case .loading:
            let section = TableSection(name: NSLS("HL_HOTEL_DETAIL_HEADER_TITLE_RATING_REVIEWS"), items: [ReviewsActivityItem()])
            return section

        case .failed:
            let errorItem = ReviewsErrorItem()
            errorItem.buttonHandler = { [weak self] in
                self?.retryLoadReviews()
            }
            return TableSection(name: NSLS("HL_HOTEL_DETAIL_HEADER_TITLE_RATING_REVIEWS"), items: [errorItem])

        case .loaded:
            return createReviewsSectionForLoadedState(variant: variant)
        case .unknown:
            return nil
        }
    }

    private func createReviewsSectionForLoadedState(variant: HLResultVariant) -> TableSection? {
        guard variant.hotel.reviews.count > 0 else { return nil }

        let reviews = variant.hotel.reviews
        let reviewItem = ReviewTextItem(review: reviews[0])
        var items: [TableItem] = [reviewItem]

        if variant.hotel.reviews.count > 1 || hasSeveralTexts(review: variant.hotel.reviews[0]) {
            let expandItem = ExpandItem()
            expandItem.selectionBlock = { [weak self] in self?.showAllReviews(reviews) }
            expandItem.title = NSLS("HL_ALL_REVIEWS_TITLE") + " (\(reviews.count)) "
            expandItem.height = 60
            expandItem.shouldShowArrow = true

            items.append(expandItem)
        }

        TableItem.setFirstAndLast(items: items)

        return TableSection(name: NSLS("HL_HOTEL_DETAIL_HEADER_TITLE_RATING_REVIEWS"), items: items)
    }

    private func hasSeveralTexts(review: HDKReview) -> Bool {
        var firstReviewTextsCount = 0

        if !review.textPlus.isEmpty {
            firstReviewTextsCount += 1
        }

        if !review.textMinus.isEmpty {
            firstReviewTextsCount += 1
        }

        if !review.text.isEmpty {
            firstReviewTextsCount += 1
        }

        return firstReviewTextsCount > 1
    }

    private func createActivitySection() -> TableSection {
        return ActivitySection(name: "", items: [ActivityItem()])
    }

    private func createErrorSection() -> TableSection {
        let errorItem = ErrorItem()
        errorItem.buttonHandler = { [weak self] in self?.reloadHotelDetails() }

        return TableSection(name: "", items: [errorItem])
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]

        return section.cell(tableView, indexPath: indexPath)
    }

    // MARK: - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let mapCell = cell as? HLHotelDetailsMapCell {
            showFullMap(zoomFrom: mapCell.mapView)
        } else {
            let item = sections[indexPath.section].items[indexPath.row]
            item.selectionBlock?()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]

        return section.heightForCell(tableView, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].headerHeight()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].headerView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == sections.count - 1 {
            return iPad() ? 15 : 20
        } else {
            return CGFloat(ZERO_HEADER_HEIGHT)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let nib = UINib(nibName: "HLGroupedTableHeaderView", bundle: nil)
        let views = nib.instantiate(withOwner: nil, options: nil).flatMap { $0 as? UIView }
        let footer = views.first
        if let groupedHeader = footer as? HLGroupedTableHeaderView {
            groupedHeader.title = ""
        }

        return footer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        decoratorDelegate?.viewWillAppear()
        setupContent()

        updatePriceInfoState(newState: pricesInfoState)
        createSections()
        contentTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        decoratorDelegate?.viewDidAppear()

        if detailState != .loading && detailState != .completed {
            let delayTime = DispatchTime.now() + 0.15
            DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
                self?.loadHotelDetailsInfo()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        visiblePhotoIndexUpdater?(photoIndex)
    }

    override func goBack() {
        if let decorator = decoratorDelegate {
            decorator.goBack()
        } else {
            super.goBack()
        }
    }

    // MARK: - Internal methods

    func loadHotelDetailsInfo() {
        decoratorDelegate?.hotelInfoWillLoad?()
        detailState = .loading
        hotelsManager.delegate = self
        hotelsManager.loadHotelDetails(for: variant.hotel)
    }

    func showPricesScreen() {
        let controller = HotelPricesVC(variant: variant)
        controller.delegate = self
        showMoreVC(moreVC: controller)
    }

    func showRatingVC() {
        showMoreVC(moreVC: HotelRatingVC(variant: variant, filter: filter))
    }

    func showMoreVC(moreVC: UIViewController) {
        if iPad() {
            customPresent(moreVC, animated: true)
        } else {
            navigationController?.pushViewController(moreVC, animated: true)
        }
    }

    // MARK: - Update controls

    func updatePriceInfoState(newState: HotelDetailsTabState) {
        if newState == .completed && variant?.filteredRooms.isEmpty ?? true {
            pricesInfoState = .noPrices
        } else {
            pricesInfoState = newState
        }
    }

    func setupContent() {
        guard self.isViewLoaded else { return }

        hotelView.update(withVariant: variant, shouldDrawBadges: iPhone())
        hotelView.currentPhotoIndex = photoIndex

        contentTableView.reloadData()
    }

    @objc private func share() {
        showWaitingView()
        prepareSharingData { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.hideWaitingView(nil)
                self.shareUrl(withShortString:self.urlShortener.shortenedUrl(), longString:self.urlShortener.longUrlString)
            }
        }
    }

    func prepareSharingData(onCompletion completionBlock: @escaping () -> Void) {
        urlShortener.shortenUrl(for: variant) {
            completionBlock()
        }
    }

    func showWaitingView() {
        if self.progressView == nil {
            self.progressView = Bundle.main.loadNibNamed("HLSpinnerProgressView", owner: nil, options: nil)?.first as? HLSpinnerProgressView
        }
        self.progressView!.show(self.view, animated:false)
    }

    func hideWaitingView(_ completion: (() -> Void)?) {
        self.progressView!.dismiss(0.3, delay:0.0, completion:completion)
    }

    func shareUrl(withShortString sharingUrlString: String, longString: String) {
        showActivityViewController(sharingUrlString)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }

    func showActivityViewController(_ sharingUrlString: String) {
        let sharingUrl = URL(string: sharingUrlString)!
        let urlProvider = SharingURLActivityItemProvider(url: sharingUrl)
        let shareController = UIActivityViewController(activityItems: [urlProvider], applicationActivities: nil)
        if iPad() {
            shareController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(shareController, animated: true, completion: nil)
    }

    func retryLoadReviews() {
        startLoadingReviewsIfNeeded()
    }

    fileprivate func startLoadingReviewsIfNeeded() {
        guard variant.hotel.reviewsCount > 0 else {
            return
        }
        let api = ServiceLocator.shared.api
        reviewsState = .loading

        api.reviews(hotelId: variant.hotel.hotelId, limit: kMaxReviewsLimit).promise().then { [weak self] reviewsResponse -> Void in
            guard let `self` = self else { return }
            self.variant.hotel.reviews = reviewsResponse.reviews
            self.reviewsState = .loaded
        }.catch { [weak self] _ in
            self?.reviewsState = .failed
        }
    }
}

extension HLHotelDetailsVC: HLHotelDetailsTabCellDelegate {
    // MARK: - HLHotelsManagerDelegate methods

    func hotelsManagerDidLoadHotelDetails(_ hotel: HDKHotel!) {
        let dispatchTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: { [weak self] in
            guard let `self` = self else {
                return
            }

            self.hotelDetailsDidLoad(hotel)
            })
    }

    func hotelsManagerFailedWithError(_ error: Error?) {
        hl_dispatch_main_async_safe {
            HLAlertsFabric.showSearchAlertViewWithError(error, handler: nil)
        }

        let dispatchTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: { [weak self] in
            self?.decoratorDelegate?.hotelInfoDidLoad?(withError: error as NSError?)
            self?.detailState = .failed
            })
    }

    func hotelsManagerCancelled() {
        let error = NSError(code:  HLErrorCode(rawValue: NSURLErrorCancelled)!)
        self.hotelsManagerFailedWithError(error)

        self.decoratorDelegate?.hotelInfoDidLoad?(withError: error)
    }

    func hotelDetailsDidLoad(_ hotel: HDKHotel) {
        if !(hotelView.hotel?.isValid() ?? false) && hotel.isValid() {
            variant.searchInfo.hotel = hotel
            variant.searchInfo.city = hotel.city
            variant.hotel = hotel

            setupContent()
        }

        detailState = .completed
        variant.hotel = hotel

        decoratorDelegate?.hotelInfoDidLoad?(withError: nil)
        startLoadingReviewsIfNeeded()
        contentTableView.reloadData()
    }

    // MARK: - ReviewsVCDelegate

    private func handleReviewLogoClicked(review: HDKReview, fromViewController viewController: UIViewController) {
        guard HDKGate.isBooking(gateId: review.gate.gateId) else { return }
        let cheapestBookingRoom = variant
            .roomsCopy()?
            .filter { HDKGate.isBooking(gateId: $0.gate.gateId) }
            .sorted { $0.price < $1.price }
            .first

        if let room = cheapestBookingRoom {
            bookRoomFromReviews(room: room, fromViewController: viewController)
        } else {
            openReviewLinkInBrowser(review: review, fromViewController: viewController)
        }
    }

    func reviewLogoClicked(review: HDKReview, fromViewController viewController: UIViewController) {
        handleReviewLogoClicked(review: review, fromViewController: viewController)
    }

    // MARK: - HLHotelDetailsTabCellDelegate methods

    func minTopOffset() -> CGFloat {
        return 0.0
    }

    func topContentInset() -> CGFloat {
        return 0.0
    }

    func reloadHotelDetails() {
        self.loadHotelDetailsInfo()
        self.contentTableView.reloadData()
    }

    func gateLogoClicked(review: HDKReview) {
        handleReviewLogoClicked(review: review, fromViewController: self)
    }

    private func openReviewLinkInBrowser(review: HDKReview, fromViewController viewController: UIViewController) {
        if let urlString = review.url, let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            viewController.present(safariVC, animated: true)
        }
    }

    func startSearchVariant(_ searchInfo: HLSearchInfo) {
    }

    func bookRoomFromReviews(room: HDKRoom, fromViewController viewController: UIViewController) {
        bookRoom(room, fromViewController: viewController)
    }

    func bookRoom(_ room: HDKRoom) {
        bookRoom(room, fromViewController: self)
    }

    func bookRoom(_ room: HDKRoom, fromViewController viewController: UIViewController) {
        guard !variant.isGateOutdated(room.gate) else {
            HLAlertsFabric.showOutdatedResultsAlert({
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popToRootViewController(animated: true)
            })
            return
        }
        let browser = BookBrowserController(nibName: "BookBrowserController", bundle: nil)
        browser.room = room
        browser.providesPresentationContextTransitionStyle = true
        browser.definesPresentationContext = true
        if viewController.presentedViewController != nil {
            viewController.dismiss(animated: true, completion: {
                viewController.present(browser, animated: true, completion: nil)
            })
        } else {
            viewController.present(browser, animated: true, completion: nil)
        }
    }

    func showFullMap(zoomFrom mapView: HLMapView) {
        let mapVC = ZoomKeepingPeekVC(nibName: "SingleHotelMapVC", bundle: nil)
        mapVC.variant = variant
        mapVC.filter = filter
        mapVC.setZoom(from: mapView)

        showMoreVC(moreVC: mapVC)
    }

    func showDistancePoints() {
        let mapVC = ImportantPointsMapVC(nibName: "SingleHotelMapVC", bundle: nil)
        mapVC.variant = variant
        mapVC.filter = filter
        showMoreVC(moreVC: mapVC)
    }

    func showAllReviews(_ reviews: [HDKReview]) {
        let vc = ReviewsVC(reviews: reviews, variant: variant)
        vc.delegate = self
        showMoreVC(moreVC: vc)
    }

    func showPhotoAtIndex(_ index: Int) {
    }

    func photosColumnsCount() -> Int {
        return 3
    }

    func photoGridViewCellDidHighlight(_ cell: HLPhotoScrollCollectionCell) {
        cell.applyHightlightedStyle(cell.isHighlighted, animated: true)
    }

    func showPhotosScreen() {
        let galleryVC = HotelGalleryVC(variant: variant)
        navigationController?.pushViewController(galleryVC, animated: true)
    }
}
