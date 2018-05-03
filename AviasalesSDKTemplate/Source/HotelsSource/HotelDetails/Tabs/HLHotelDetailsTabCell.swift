@objc protocol HLHotelDetailsTabCellDelegate: ReviewCellDelegate, BookRoomDelegate {
    func minTopOffset() -> CGFloat
    func topContentInset() -> CGFloat
    func reloadHotelDetails()
    func startSearchVariant(_ searchInfo: HLSearchInfo)
    func showFullMap(zoomFrom mapView: HLMapView)
    func showDistancePoints()
    func showPhotosScreen()
    func showPricesScreen()
    func showPhotoAtIndex(_ index: Int)
    func photosColumnsCount() -> Int
    func showAllReviews(_ reviews: [HDKReview])
    func retryLoadReviews()

    @objc optional func footerHeightForContentSize(_ contentSize: CGSize) -> CGFloat
    @objc optional func photoGridViewCellDidSelect(_ cell: HLPhotoScrollCollectionCell)
    @objc optional func photoGridViewCellDidHighlight(_ cell: HLPhotoScrollCollectionCell)
}

class HLHotelDetailsTabCell: UICollectionViewCell {

    var variant: HLResultVariant?
    var hlScrollView: UIScrollView?
    var hlTabContentView: UIView?
    var hotelInfoState: HotelDetailsTabState = .none
    var pricesInfoState: HotelDetailsTabState = .none

    var contentOffset: CGFloat = 0.0 {
        didSet {
            let point = CGPoint(x: 0.0, y: self.contentOffset)
            hlScrollView!.setContentOffset(point, animated: false)
        }
    }

    weak var delegate: HLHotelDetailsTabCellDelegate?

    let kSmallSectionHeaderHeight: CGFloat = 20.0

    func lastSectionFooterHeight() -> CGFloat {
        return delegate?.footerHeightForContentSize?(hlScrollView!.contentSize) ?? kSmallSectionHeaderHeight
    }

    // MARK: - Override methods

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    override var bounds: CGRect {
        didSet {
            self.contentView.frame = self.bounds
        }
    }

    // MARK: - Internal methods

    func createTabContentViewAndScrollView() -> (UIView?, UIScrollView?) {
        assertionFailure("createScrollView() must be implemented in subclass")
        return (UIView(), UIScrollView())
    }

    func initialize() {
        self.backgroundColor = UIColor.clear

        (hlTabContentView, hlScrollView) = createTabContentViewAndScrollView()
        self.contentView.addSubview(hlTabContentView!)
        hlTabContentView!.autoPinEdgesToSuperviewEdges()

        if iPad() {
            hlScrollView!.showsVerticalScrollIndicator = false
        } else {
            let topInset = delegate?.topContentInset() ?? 0.0
            hlScrollView!.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }

    func updateHotelInfoContent(_ hotelInfoState: HotelDetailsTabState) {

        if self.hotelInfoState != hotelInfoState {
            self.hotelInfoState = hotelInfoState
            self.performContentUpdate()
        } else {
            self.fixTwoColumnCells(hotelInfoState)
        }
    }

    func fixTwoColumnCells(_ hotelInfoState: HotelDetailsTabState) {
        if iPad() && hotelInfoState == .completed {
            self.performContentUpdate()
        }
    }

    func updatePricesInfoContent(_ priceState: HotelDetailsTabState) {
        if priceState == .loading {
            pricesInfoState = .loading
        } else if noRoomsFound(priceState) {
            pricesInfoState = .noPrices
        } else {
            pricesInfoState = priceState
        }
        performContentUpdate()
    }

    func performContentUpdate() {
        // override in subclass
    }

    // MARK: - Private methods

    fileprivate func noRoomsFound(_ priceState: HotelDetailsTabState) -> Bool {
        return priceState == .completed && variant?.filteredRooms.count ?? 0 == 0
    }
}
