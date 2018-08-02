import Appodeal

@objcMembers
class WaitingVC: HLCommonVC, HLVariantsManagerDelegate, HLCityInfoLoadingProtocol,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HLDeceleratingProgressAnimatorDelegate, AppodealInterstitialDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var waitingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var progressView: UIProgressView!

    let kAverageSearchDuration: TimeInterval = 10.0
    let kCollectionViewFadeDuration: TimeInterval = 0.5
    let kFinishingSearchDuration: TimeInterval = 0.5

    let cellFactory = WaitingCellFactory()
    let variantsManager = HLVariantsManager()
    let citiesByPointDetector = HLCitiesByPointDetector()

    var gateItemsMap: [String: GateItem] = [:]

    var waitingItems: [WaitingLoadingItem] = []
    var sections: [WaitingSection] = []
    var searchInfo: HLSearchInfo!

    let progressAnimator = HLDeceleratingProgressAnimator()

    private var showErrorAction: (() -> Void)?
    private var canShowError = true {
        didSet {
            if canShowError {
                showErrorAction?()
                showErrorAction = nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = searchInfo.city?.name

        collectionView.backgroundColor = JRColorScheme.mainBackgroundColor()
        cellFactory.registerNibs(collectionView)
        var insets = collectionView.contentInset
        insets.bottom += 10.0 + kNavBarHeight
        if iPad() {
            insets.bottom += 30.0
        }
        collectionView.contentInset = insets

        waitingActivityIndicator.startAnimating()
        tryStartSearch()
        addLongSearchSection()

        addSearchInfoView(searchInfo)

        Appodeal.setInterstitialDelegate(self)
        Appodeal.showAd(.interstitial, rootViewController: self.navigationController ?? self)

        progressView.trackTintColor = UIColor.clear
        progressView.progressTintColor = JRColorScheme.actionColor()
        progressAnimator.delegate = self
        startProgress()
    }

    override func goBack() {
        navigationController?.popViewController(animated: true)
    }

    private func addLongSearchSection() {
        let longSearchSection = WaitingSection()
        longSearchSection.items = [WaitingLongSearchItem()]
        sections.append(longSearchSection)
    }

    func tryStartSearch() {
        let canStartImmediatelly = !searchInfo.isSearchByLocation() && searchInfo.searchInfoType != .userLocation
        if canStartImmediatelly {
            startSearch()
        } else {
            citiesByPointDetector.detectNearbyCitiesForSearchInfo(searchInfo, onCompletion: { [weak self](nearbyCities: [HDKCity]) in

                guard nearbyCities.count > 0 else {
                    self?.onSearchError(NSError(serverWith: HLErrorCode.noNearbyCitiesError))
                    return
                }

                self?.searchInfo.locationPoint?.nearbyCities = nearbyCities
                self?.startSearch()

                }, onError: { [weak self](error) in
                    self?.onSearchError(error)
            })
        }
    }

    // MARK: - AppodealInterstitialDelegate

    func interstitialWillPresent() {
        canShowError = false
    }

    func interstitialDidDismiss() {
        canShowError = true
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        return item.accept(cellFactory, collectionView: collectionView, indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]

        let width = collectionView.bounds.size.width
        return CGSize(width: width, height: item.cellHeight(containerWidth: width))
    }

    // MARK: - HLDeceleratingProgressAnimatorDelegate

    func progressChanged(_ progress: CGFloat) {
        progressView.progress = Float(progress)
    }

    // MARK: - HLCityInfoLoadingProtocol

    func variantsManagerSearchRoomsStarted(with gates: [HDKGate]) {
        waitingItems = gates.map { return GateItem(gate: $0) }
        waitingItems.append(OtherGatesItem())

        gateItemsMap = waitingItems.hdk_toDictionary { (element: WaitingItem) -> (key: String, value: GateItem)? in
            guard let gateItem = element as? GateItem else { return nil }
            return (gateItem.gate.gateId, gateItem)
        }

        let section = WaitingSection()
        section.items = waitingItems.map { $0 as WaitingItem }
        sections.append(section)

        hl_dispatch_main_sync_safe {() -> Void in
            self.waitingActivityIndicator.stopAnimating()
            self.collectionView.reloadData()
            UIView.animate(withDuration: self.kCollectionViewFadeDuration, animations: {
                self.collectionView.alpha = 1.0
            })
        }
    }

    func variantsManagerSearchRoomsDidReceiveData(fromGatesIds gateIds: [String]) {
        hl_dispatch_main_sync_safe {
            for gateId in gateIds {
                self.gateItemsMap[gateId]?.isLoaded = true
            }
            for cell in self.collectionView.visibleCells {
                if let gateCell = cell as? WaitingGateCell, let gateItem = gateCell.gateItem {
                    gateCell.configureForGateItem(gateItem)
                }
            }
        }
    }

    func variantsManagerFinished(_ searchResult: SearchResult) {
        goToResults(searchResult)
    }

    fileprivate func goToResults(_ searchResult: SearchResult) {
        hl_dispatch_main_async_safe {
            self.progressAnimator.stop(withDuration: self.kFinishingSearchDuration)
            self.markAllCellsAsLoaded()
            let dispatchTime = DispatchTime.now() + self.kFinishingSearchDuration
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.moveToResultsVCVariants(searchResult)
            })
        }
    }

    func markAllCellsAsLoaded() {
        for var item in waitingItems {
            item.isLoaded = true
        }
        collectionView.reloadData()
    }

    func variantsManagerFailedWithError(_ error: Error) {
        hl_dispatch_main_async_safe {
            self.waitingActivityIndicator.stopAnimating()
            self.progressAnimator.stop(withDuration: 0)
            self.onSearchError(error)
        }
    }

    func variantsManagerCancelled() {
    }

    // MARK: - Private methods

    private func onSearchError(_ error: Error) {

        let showErrorAction: (() -> Void)? = {
            hl_dispatch_main_sync_safe {
                HLAlertsFabric.showSearchAlertViewWithError(error, handler: { _ in
                    self.goBack()
                })
            }
        }

        if canShowError {
            showErrorAction?()
        } else {
            self.showErrorAction = showErrorAction
        }
    }

    private func citiesForSearchInfo(_ searchInfo: HLSearchInfo) -> [HDKCity] {
        if let city = searchInfo.city {
            return [city]
        }
        return searchInfo.locationPoint?.nearbyCities ?? []
    }

    private func startSearch() {
        variantsManager.delegate = self
        variantsManager.searchInfo = searchInfo
        variantsManager.startCitySearch()
    }

    private func startProgress() {
        progressView.progress = 0.0
        progressAnimator.start(withDuration: kAverageSearchDuration)
    }

    private func moveToResultsVCVariants(_ searchResult: SearchResult) {
        let resultsVC = iPad()
            ? HLIpadResultsVC(nibName: "HLIpadResultsVC", bundle: nil)
            : HLIphoneResultsVC(nibName: "HLIphoneResultsVC", bundle: nil)

        resultsVC.searchInfo = searchInfo.copy() as! HLSearchInfo
        resultsVC.setSearchResult(searchResult: searchResult)

        if let navController = navigationController {
            var controllers = navController.viewControllers
            let lastIndex = controllers.count - 1
            controllers[lastIndex] = resultsVC
            navController.setViewControllers(controllers, animated: true)
        }
    }

}
