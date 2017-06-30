import UIKit

class HLHotelDetailsSearchDecorator: HLHotelDetailsDecorator, HLHotelDetailsTabCellDelegate, HLVariantsManagerDelegate {

    var variantState: HotelDetailsTabState = .none {
        didSet {
            detailsVC.updatePriceInfoState(newState: variantState)
        }
    }

    fileprivate var variantsManager: HLVariantsManager?

    var needToStartSearchImmediately: Bool = true
    var needToSelectSearchParameters: Bool = false

    // MARK: - HLHotelDetailsDecoratorProtocol methods

    override func viewDidLoad() {
        super.viewDidLoad()

        detailsVC.loadHotelDetailsInfo()

        if needToStartSearchImmediately {
            startSearchVariant(detailsVC.variant.searchInfo)
        } else if needToSelectSearchParameters {
            variantState = .searchInfoSelectionNeeded
        } else {
            variantState = .completed
        }
    }

    // MARK: - Public methods

    func updateVariant(_ variant: HLResultVariant) {
        variant.hotel = detailsVC.variant.hotel
        detailsVC.variant = variant
        variantState = .completed
    }

    // MARK: - HLHotelDetailsTabCellDelegate methods

    func minTopOffset() -> CGFloat {
        return detailsVC.minTopOffset()
    }

    func topContentInset() -> CGFloat {
        return detailsVC.topContentInset()
    }

    func reloadHotelDetails() {
        detailsVC.reloadHotelDetails()
    }

    func showFullMap(zoomFrom mapView: HLMapView) {
        detailsVC.showFullMap(zoomFrom: mapView)
    }

    func showDistancePoints() {
        detailsVC.showDistancePoints()
    }

    func showAllReviews(_ reviews: [HDKReview]) {
        detailsVC.showAllReviews(reviews)
    }

    func retryLoadReviews() {
        detailsVC.retryLoadReviews()
    }

    func showPhotoAtIndex(_ index: Int) {
        detailsVC.showPhotoAtIndex(index)
    }

    func photosColumnsCount() -> Int {
        return detailsVC.photosColumnsCount()
    }

    func bookRoom(_ room: HDKRoom) {
        detailsVC.bookRoom(room)
    }

    func gateLogoClicked(review: HDKReview) {
        detailsVC.gateLogoClicked(review: review)
    }

    func showPhotosScreen() {
        detailsVC.showPhotosScreen()
    }

    func showPricesScreen() {
        detailsVC.showPricesScreen()
    }

    func startSearchVariant(_ searchInfo: HLSearchInfo) {
        variantState = .loading

        detailsVC.variant.searchInfo = searchInfo
        detailsVC.contentTableView.reloadData()

        let variantsManager = HLVariantsManager()
        variantsManager.delegate = self
        variantsManager.searchInfo = detailsVC.variant.searchInfo
        variantsManager.startHotelSearch(detailsVC.variant.hotel)
        self.variantsManager = variantsManager
    }

    func owner() -> UIViewController? {
        return detailsVC
    }

    // MARK: - HLVariantsManagerDelegate methods

    func variantsManagerFinished(_ searchResult: SearchResult) {
        if let variant = searchResult.variants.first {
            updateVariant(variant)
        } else {
            variantState = .failed
        }

        detailsVC.setupContent()
    }

    func variantsManagerFailedWithError(_ error: Error?) {
        HLAlertsFabric.showSearchAlertViewWithError(error, handler: nil)
        setFailedState()
    }

    func variantsManagerCancelled() {
        setFailedState()
    }

    fileprivate func setFailedState() {
        variantState = .failed
        detailsVC.contentTableView.reloadData()
    }
}
