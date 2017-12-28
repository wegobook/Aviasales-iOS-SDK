//
//  HLCommonResultsVC.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 09/03/2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

class HLCommonResultsVC: HLCommonVC,
    HLPlaceholderViewDelegate,
    HLFilterDelegate,
    PointSelectionDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    FiltersVCDelegate,
    HLActionCellDelegate,
    UICollectionViewDelegate,
    HLMosaicCollectionViewLayoutItemsProtocol {

    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet private(set) weak var collectionView: UICollectionView!

    var mapButton: UIBarButtonItem?

    var variants: [HLResultVariant] = []
    var filter = Filter()
    var searchInfo: HLSearchInfo! {
        didSet {
            filter.searchInfo = searchInfo
        }
    }

    private var noSearchResultsView: HLPlaceholderView!
    private var noFiltersResultView: HLPlaceholderView!
    private var needUpdateContent = false

    var items: [HLCollectionItem] = []
    private let actionCardsManager = HLActionCardsManager()

    var collectionLayout: UICollectionViewFlowLayout {
        let defaultItemInset: CGFloat = 3.0
        var layout: UICollectionViewFlowLayout!
        if iPad() {
            layout = HLResultsMosaicCollectionViewLayout()
            layout.sectionInset = UIEdgeInsets(top: defaultItemInset, left: defaultItemInset, bottom: defaultItemInset, right: defaultItemInset)
            layout.minimumLineSpacing = defaultItemInset
            layout.minimumInteritemSpacing = 0.0
            (layout as! HLMosaicCollectionViewLayout).itemsDelegate = self
        } else {
            layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            layout.minimumInteritemSpacing = 0.0
            layout.minimumLineSpacing = defaultItemInset
        }
        layout.scrollDirection = .vertical

        return layout
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Results"

        let sel = #selector(showMap)
        mapButton = UIBarButtonItem(title: NSLS("HL_MAP_BUTTON"), style: .plain, target: self, action: sel)
        navigationItem.rightBarButtonItem = mapButton
        addSearchInfoView(searchInfo)

        if let markImage = UIImage(named:"filtersButtonActive") {
            filtersButton?.setImage(markImage, for: .selected)
            filtersButton?.setImage(markImage, for: [.selected, .highlighted])
        }

        filtersButton.backgroundColor = JRColorScheme.actionColor()
        filtersButton.setTitleColor(.white, for: .normal)

        collectionView.collectionViewLayout = collectionLayout
        collectionView.allowsSelection = false
        registerNibs()
        addPlaceholders()

        filtersButton.setTitle(NSLS("HL_FILTER_BUTTON_TITLE_LABEL"), for: .normal)
        sortButton.setTitle(NSLS("HL_SORT_BUTTON_TITLE_LABEL"), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateContentIfNeeded()
        filter.delegate = self
        setFiltersButtonSelected(filter.canDropFilters())
    }

    func setFiltersButtonSelected(_ selected: Bool) {
        filtersButton?.isSelected = selected
    }

    private func registerNibs() {
        let nibName = "HLVariantScrollablePhotoCell"
        let nib = UINib(nibName: nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: HLVariantCollectionViewCell.hl_reuseIdentifier())

        actionCardsManager.registerCardNibs(for: collectionView)
    }

    func presentSortVC(_ sortVC: HLSortVC, animated: Bool) {
        sortVC.searchInfo = searchInfo
    }

    func createItems(_ variants: [HLResultVariant]) -> [HLCollectionItem] {
        let variantItems = HLVariantItem.createItems(variants)
        let configuration = ActionCardsConfiguration(searchInfo: searchInfo, filter: filter, delegate: self)

        return actionCardsManager.addActionCards(to: variantItems, configuration: configuration) ?? []
    }

    func setSearchResult(searchResult: SearchResult) {
        variants = searchResult.variants

        filter.setDefaultLocationPointWith(searchInfo)
        filter.searchResult = searchResult
        filter.refreshPriceBounds()
        filter.filter()
        needUpdateContent = (filter.searchResult.variants.count == 0)

        items = createItems(variants)
    }

    func updateContentWithVariants(_ variants: [HLResultVariant], filteredVariants: [HLResultVariant]) {
        if !isViewLoaded {
            needUpdateContent = true
            return
        }

        setFiltersButtonSelected(filter.canDropFilters())
        if variants.count > 0 && filteredVariants.count > 0 {
            noSearchResultsView.isHidden = true
            noFiltersResultView.isHidden = true
            collectionView.isHidden = false
            sortButton?.isHidden = false
            filtersButton?.isHidden = false

            items = createItems(filteredVariants)
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }

        if variants.count > 0 && filteredVariants.count == 0 {
            noSearchResultsView.isHidden = true
            noFiltersResultView.isHidden = false
            collectionView.isHidden = true
        }

        if variants.count == 0 {
            noSearchResultsView.isHidden = false
            noFiltersResultView.isHidden = true
            collectionView.isHidden = true
            sortButton?.isHidden = true
            filtersButton?.isHidden = true
        }
        needUpdateContent = false
    }

    func showMap() {
        let mapVC = createMapVC()
        mapVC.searchInfo = searchInfo
        mapVC.filter = filter
        navigationController?.pushViewController(mapVC, animated:true)
        mapVC.variantsFiltered(filter.filteredVariants, animated:true)
    }

    func createMapVC() -> HLMapVC {
        return HLIphoneMapVC(nibName: "HLIphoneMapVC", bundle:nil)
    }

    func createFiltersVC() -> HLFiltersVC {
        let filtersVC: HLFiltersVC
        if iPad() {
            filtersVC = HLIpadFiltersVC(nibName: "HLIpadFiltersVC", bundle: nil)
        } else {
            filtersVC = HLIphoneFiltersVC(nibName: "HLIphoneFiltersVC", bundle: nil)
        }
        filtersVC.searchInfo = searchInfo
        filtersVC.filter = filter

        return filtersVC
    }

    func updateContentIfNeeded() {
        if needUpdateContent {
            updateContentWithVariants(filter.allVariants, filteredVariants: filter.filteredVariants)
        }
    }

    private func addPlaceholders() {
        addNoResultsPlaceholder()
        addNoFilterResultsPlaceholder()
    }

    private func addNoResultsPlaceholder() {
        noSearchResultsView = loadViewFromNibNamed("HLNoSearchResultsPlaceholderView") as! HLPlaceholderView
        noSearchResultsView.delegate = self
        noSearchResultsView.isHidden = true
        view.addSubview(noSearchResultsView)
        noSearchResultsView.autoPinEdgesToSuperviewEdges()
    }

    private func addNoFilterResultsPlaceholder() {
        noFiltersResultView = loadViewFromNibNamed("HLNoFilterResultsPlaceholderView") as! HLPlaceholderView
        noFiltersResultView.delegate = self
        noFiltersResultView.isHidden = true
        if iPad() {
            collectionView.superview?.addSubview(noFiltersResultView)
            noFiltersResultView.autoPinEdge(.left, to: .left, of: collectionView)
            noFiltersResultView.autoPinEdge(.right, to: .right, of: collectionView)
            noFiltersResultView.autoPinEdge(.top, to: .top, of: collectionView)
            noFiltersResultView.autoPinEdge(.bottom, to: .bottom, of: collectionView)
        } else {
            view.insertSubview(noFiltersResultView, belowSubview: collectionView)//buttonsView)
            noFiltersResultView.autoPinEdgesToSuperviewEdges()
        }
    }

    func showFilters(animated: Bool) {
        let filtersVC = createFiltersVC()
        if let topVC = navigationController?.topViewController as? FiltersVCDelegate {
            filtersVC.delegate = topVC
        }
        navigationController?.pushViewController(filtersVC, animated: true)
    }

    @IBAction func showFilters() {
        showFilters(animated: true)
    }

    @IBAction func showSort() {
        let sortVC = HLSortVC(nibName: "HLSortVC", bundle: nil)
        sortVC.filter = filter
        sortVC.sortDidApply = { [weak self] in
            self?.sortDidApply()
        }
        presentSortVC(sortVC, animated: true)
    }

    private func removeItem(_ item: HLCollectionItem) {
        self.collectionView.performBatchUpdates({ () -> Void in
            if let index = self.items.index(of: item) {
                self.items.removeObject(item)
                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }
        }, completion:nil)
    }

    func setNeedsUpdateContent() {
        needUpdateContent = true
    }

    // MARK: - SortDelegate Methods

    func sortDidApply() {
    }

    // MARK: - HLFilterDelegate Methods

    func didFilterVariants() {
        updateContentWithVariants(filter.allVariants, filteredVariants: filter.filteredVariants)
    }

    // MARK: - HLResultsViewControllerProtocol Methods

    func dropFilters() {
        filter.dropFilters()
    }

    // MARK: - PointSelectionDelegate

    func openPointSelectionScreen() {
    }

    func locationPointSelected(_ point: HDKLocationPoint) {
        filter.distanceLocationPoint = point
        filter.filter()
    }

    // MARK: - ChooseSelectionDelegate

    func showSelectionViewController(_ selectionVC: FilterSelectionVC) {

    }

    // MARK: - UICollectionViewDataSource Methods

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        if let variantItem = item as? HLVariantItem {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HLVariantCollectionViewCell.hl_reuseIdentifier(), for: indexPath) as! HLVariantCollectionViewCell
            cell.setup(with: variantItem)
            cell.selectionHandler = { [weak self, weak collectionView] (variant: HLResultVariant?, index: UInt) -> Void in
                guard let collection  = collectionView, let `self` = self else { return }
                self.collectionView(collection, didSelectItemAt: self.collectionView.indexPath(for: cell)!)
            }

            return cell
        } else if let actionItem = item as? HLActionCardItem {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: actionItem.cellReuseIdentifier, for: indexPath) as! HLResultCardCell
            cell.item = actionItem

            return cell
        } else {
            return UICollectionViewCell()
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout methods

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.item]
        if let actionCardItem = item as? HLActionCardItem {
            return CGSize(width: collectionView.bounds.size.width, height: actionCardItem.height)
        } else {
            if let layout = self.collectionView?.collectionViewLayout as? HLMosaicCollectionViewLayout {
                return layout.layoutAttributesForItem(at: indexPath)?.frame.size ?? CGSize(width: 100, height: 100)
            } else {
                return CGSize(width: collectionView.bounds.size.width, height: HLPhotoScrollView.preferredHeight())
            }
        }
    }

    // MARK: - HLActionCellDelegate Methods

    func actionCardItemClosed(_ item: HLCollectionItem!) {
        removeItem(item)
        actionCardsManager.excludeItemClass(item as! HLActionCardItem)
    }

    func distanceItemClosed(_ item: HLDistanceFilterCardItem!) {
    }

    func distanceItemApplied(_ item: HLDistanceFilterCardItem!) {
        actionCardsManager.excludeItemClass(item)
        filterUpdated(item.filter)
    }

    func nearbyCitiesSearchItemApplied(_ item: HLCollectionItem!) {
        let searchInfoWithLocationPoint = self.searchInfo.copy() as! HLSearchInfo
        searchInfoWithLocationPoint.locationPoint = HLSearchCityCenterLocationPoint(city: searchInfo.city!, nearbyCities: [])

        let waitingVC = WaitingVC(nibName: "WaitingVC", bundle: nil)
        waitingVC.searchInfo = searchInfoWithLocationPoint

        if let navVC = navigationController as? JRNavigationController {
            let oldControllers = navVC.viewControllers
            let newControllers = [oldControllers[0], waitingVC]
            navVC.setViewControllers(newControllers, animated: true)
        }
    }

    func filterUpdated(_ filter: Filter!) {
        self.filter = filter
        self.filter.filter()
    }

    func searchTickets() {
        InteractionManager.shared.applySavedTicketsSearchInfo()
    }

    // MARK: - UICollectionViewDelegate methods

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetailsForIndexPath(indexPath, animated: true)
    }

    func showDetailsForIndexPath(_ indexPath: IndexPath, animated: Bool) {
        let item = items[indexPath.row] as! HLVariantItem
        let variant = item.variant
        var currentPhotoIndex: Int = 0
        if let cell = collectionView.cellForItem(at: indexPath) as? HLVariantScrollablePhotoCell {
            currentPhotoIndex = cell.visiblePhotoIndex
        }

        let decorator = HLHotelDetailsDecorator(variant: variant, photoIndex: currentPhotoIndex, photoIndexUpdater: nil, filter: filter)
        navigationController?.pushViewController(decorator.detailsVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let c = cell as? HLVariantScrollablePhotoCell {
            if let item = c.item {
                item.photoIndex = c.visiblePhotoIndex
            }
        }
        if let c = cell as? HLVariantCollectionViewCell {
            c.resetContent()
        }
    }

    // MARK: - HLMosaicCollectionViewLayoutItemsProtocol Methods

    func currentItemsInSection(_ section: Int) -> [HLCollectionItem] {
        return items
    }

}
