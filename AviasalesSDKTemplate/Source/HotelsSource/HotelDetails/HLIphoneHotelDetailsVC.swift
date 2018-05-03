class HLIphoneHotelDetailsVC: HLHotelDetailsVC, HLPhotoScrollVCDelegate, UIViewControllerPreviewingDelegate {
    fileprivate let updateNavBarProgress: CGFloat = 0.8

    @IBOutlet fileprivate weak var photosViewTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var photosViewHeightConstraint: NSLayoutConstraint!

    fileprivate var photosCollectionExpanded: Bool = true

    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()

        photosViewHeightConstraint.constant = HLPhotoScrollView.preferredHeight()
        hotelView.setNeedsLayout()
        hotelView.layoutIfNeeded()

        hideControls(animated: false)

        hotelView.selectPhotoHandler = { [weak self] (index: Int) -> Void in
            guard let `self` = self else { return }
            self.hotelView.hideGradients(animated: true)
            self.hotelView.hideInfoControls(animated: true)
            self.hideControls(animated: true, completion: { [weak self] (finished) -> Void in
                guard let `self` = self else { return }
                self.showPhotosScreen()
                })
        }

        decoratorDelegate?.viewDidLoad()

        if #available(iOS 9.0, *) {
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        hotelView.showGradients(animated: true)
        hotelView.showInfoControls(animated: true)
        showControls(animated: true)
    }

    private func hideControls(animated: Bool, completion: ((_ success: Bool) -> Void)? = nil) {
        setControlsAlpha(0.0, animated: animated, completion: completion)
    }

    private func showControls(animated: Bool, completion: ((_ success: Bool) -> Void)? = nil) {
        setControlsAlpha(1.0, animated: animated, completion: completion)
    }

    private func setControlsAlpha(_ alpha: CGFloat, animated: Bool, completion: ((_ success: Bool) -> Void)? = nil) {
        let duration = animated ? 0.15 : 0.0
        UIView.animate(withDuration: duration,
                       animations: { () -> Void in
                        self.hotelView.badgesContainerView.alpha = alpha
        }, completion: completion)
    }

    func mapSectionRect() -> CGRect? {
        if let section = locationSection, let mapIndex = sections.index(where: { (sect: TableSection) in sect === section }) {
            return rectForSection(mapIndex)
        }

        return nil
    }

    func distanceSectionRect() -> CGRect? {
        if let section = locationSection, let distanceIndex = sections.index(where: { (sect: TableSection) in sect === section }) {
            return rectForSection(distanceIndex)
        }

        return nil
    }

    func rectWithoutHeader(_ section: Int) -> CGRect {
        let headerRect = contentTableView.rectForHeader(inSection: section)
        var sectionRect = contentTableView.rect(forSection: section)
        sectionRect.origin.y += headerRect.size.height
        sectionRect.size.height -= headerRect.size.height
        sectionRect = view.convert(sectionRect, from: contentTableView)

        return sectionRect
    }

    func rectForSection(_ section: Int) -> CGRect {
        var sectionRect = contentTableView.rect(forSection: section)
        sectionRect = view.convert(sectionRect, from: contentTableView)

        return sectionRect
    }

    func rectForHeader(_ section: Int) -> CGRect {
        var headerRect = contentTableView.rectForHeader(inSection: section)
        headerRect = view.convert(headerRect, from: contentTableView)

        return headerRect
    }

    // MARK: - HLPhotoScrollVCDelegate

    func photoScrollDidClose(_ photoScrollVC: HLPhotoScrollVC) {
        photoScrollVC.dismiss(animated: true, completion: nil)
    }

    // MARK: - UIViewControllerPreviewingDelegate

    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let cell = didHitMapCell(location) {
            if let sourceRect = mapSectionRect() {
                previewingContext.sourceRect = sourceRect
            }

            return createPeekMapVC(variant, mapView: cell.mapView)
        }

        if didHitDistanceCell(location) != nil, let variant = self.variant {
            if let sourceRect = distanceSectionRect() {
                previewingContext.sourceRect = sourceRect
            }

            return createPeekDistanceVC(variant)
        }

        if didHitMapHeader(location), let variant = self.variant {
            if let sourceRect = distanceSectionRect() {
                previewingContext.sourceRect = sourceRect
            }

            return createPeekDistanceVC(variant)
        }

        if let ratingExpandCell = didHitRatingExpandCell(location), let variant = variant {
            previewingContext.sourceRect = view.convert(ratingExpandCell.frame, from: contentTableView)

            return createPeekRatingVC(variant, filter: filter)
        }

        if let reviewsExpandCell = didHitReviewsExpandCell(location) {
            previewingContext.sourceRect = view.convert(reviewsExpandCell.frame, from: contentTableView)

            return createPeekReviewsVC(variant)
        }

        if let bestPriceExpandCell = didHitBestPriceExpandCell(location) {
            previewingContext.sourceRect = view.convert(bestPriceExpandCell.frame, from: contentTableView)

            return createBestPricePeekVC(variant)
        }

        return nil
    }

    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let peekVC = viewControllerToCommit as? PeekVCProtocol {
            peekVC.commitBlock?()
        }
    }

    private func createPeekRatingVC(_ variant: HLResultVariant, filter: Filter?) -> HotelRatingVC {
        let controller = HotelRatingVC(variant: variant, filter: filter)
        controller.commitBlock = { [weak self] in self?.showRatingVC() }
        return controller
    }

    private func createPeekReviewsVC(_ variant: HLResultVariant) -> ReviewsVC {
        let controller = ReviewsVC(reviews: variant.hotel.reviews, variant: variant)
        controller.commitBlock = { [weak self] in self?.showAllReviews(variant.hotel.reviews) }
        return controller
    }

    private func createBestPricePeekVC(_ variant: HLResultVariant) -> HotelPricesVC {
        let controller = HotelPricesVC(variant: variant)
        controller.commitBlock = { [weak self] in self?.showPricesScreen() }
        return controller
    }

    private func createPeekMapVC(_ variant: HLResultVariant?, mapView: HLMapView) -> MapPeekVC {
        let peekVC = ZoomKeepingPeekVC(nibName: "MapPeekVC", bundle: nil)
        peekVC.variant = variant
        peekVC.filter = filter
        peekVC.setZoom(from: mapView)
        peekVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: ZoomKeepingPeekVC.preferredHeight())
        peekVC.commitBlock = {
            if let mapView = peekVC.mapView {
                self.showFullMap(zoomFrom: mapView)
            }
        }

        return peekVC
    }

    private func createPeekDistanceVC(_ variant: HLResultVariant) -> MapPeekVC {
        let peekVC = ImportantPointsPeekVC(nibName: "MapPeekVC", bundle: nil)
        peekVC.variant = variant
        peekVC.filter = filter
        peekVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: ImportantPointsPeekVC.preferredHeight())
        peekVC.commitBlock = { self.showDistancePoints() }

        return peekVC
    }

    // MARK: - Private

    private func didHitMapHeader(_ point: CGPoint) -> Bool {
        if let section = locationSection, let mapIndex = sections.index(where: { (sect: TableSection) in sect === section }) {
            return rectForHeader(mapIndex).contains(point)
        }

        return false
    }

    private func didHitMapCell(_ point: CGPoint) -> HLHotelDetailsMapCell? {
        return view.hl_didHitViewOfClass(allowedClasses: [HLHotelDetailsMapCell.self], point: point) as? HLHotelDetailsMapCell
    }

    private func didHitDistanceCell(_ point: CGPoint) -> HLHotelDetailsImportantPoiCell? {
        return view.hl_didHitViewOfClass(allowedClasses: [HLHotelDetailsImportantPoiCell.self], point: point) as? HLHotelDetailsImportantPoiCell
    }

    private func didHitPriceCell(_ point: CGPoint) -> HLHotelDetailsPriceTableCell? {
        return view.hl_didHitViewOfClass(allowedClasses: [HLHotelDetailsPriceTableCell.self], point: point) as? HLHotelDetailsPriceTableCell
    }

    private func didHitRatingExpandCell(_ point: CGPoint) -> ExpandCell? {
        return didHitExpandCell(forSection: ratingSection, point: point)
    }

    private func didHitReviewsExpandCell(_ point: CGPoint) -> ExpandCell? {
        return didHitExpandCell(forSection: reviewsSection, point: point)
    }

    private func didHitBestPriceExpandCell(_ point: CGPoint) -> ExpandCell? {
        return didHitExpandCell(forSection: bestPriceSection, point: point)
    }

    private func didHitExpandCell(forSection section: TableSection?, point: CGPoint) -> ExpandCell? {
        guard let section = section,
            let ratingIndex = sections.index(where: { (sect: TableSection) in sect === section }),
            let expandCell = view.hl_didHitViewOfClass(allowedClasses: [ExpandCell.self], point: point) as? ExpandCell,
            let cellIndexPath = contentTableView.indexPath(for: expandCell) else {
                return nil
        }

        return cellIndexPath.section == ratingIndex ? expandCell : nil
    }
}

// MARK: - HLIphoneHotelDetailsVC

extension HLIphoneHotelDetailsVC {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let photoScrollHeight = HLPhotoScrollView.preferredHeight()

        var transform = CATransform3DIdentity

        let newOffset: CGFloat
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top

        if offset <= 0 {
            newOffset = 0
        } else {
            let lim = photoScrollHeight
            newOffset = min(max(0.0, offset), lim)
        }

        if offset > 0 {
            photosViewTopConstraint.constant = -newOffset
            photosViewHeightConstraint.constant = photoScrollHeight

            hotelView.isUserInteractionEnabled = false
        } else {
            let scale = min(1.0 + -offset / photoScrollHeight, 1.7)

            transform = CATransform3DMakeScale(scale, scale, 1.0)

            photosViewTopConstraint.constant = 0.0
            photosViewHeightConstraint.constant = photoScrollHeight - offset

            hotelView.isUserInteractionEnabled = true
        }

        hotelView.setNeedsUpdateConstraints()
        hotelView.updateConstraintsIfNeeded()
        hotelView.setNeedsLayout()
        hotelView.layoutIfNeeded()

        hotelView.contentTransform = transform
    }

    override func topContentInset() -> CGFloat {
        return HLPhotoScrollView.preferredHeight()
    }

    override func showPhotoAtIndex(_ index: Int) {
        super.showPhotoAtIndex(index)

        let vc = HLPhotoScrollVC()
        vc.hotel = variant.hotel
        vc.currentPhotoIndex = index
        vc.delegate = self
        vc.view.backgroundColor = UIColor.black

        present(vc, animated: true, completion: nil)
    }
}
