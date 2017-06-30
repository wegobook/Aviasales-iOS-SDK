//
//  ASTWaitingScreenPresenter.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

protocol ASTWaitingScreenViewProtocol: NSObjectProtocol {

    func startAnimating()
    func animateProgress(duration: TimeInterval)
    func update(title: String)
    func updateInfo(text: String, range: NSRange)
    func showAppodealAdvertisement()
    func showAviasalesAdvertisement(searchInfo: JRSDKSearchInfo)
    func showSearchResults(searchResult: JRSDKSearchResult, searchInfo: JRSDKSearchInfo)
    func showError(title: String, message: String, cancel: String)
    func pop()
}

class ASTWaitingScreenPresenter: NSObject {

    weak var view: ASTWaitingScreenViewProtocol?

    let searchInfo: JRSDKSearchInfo
    let searchPerformer = AviasalesSDK.sharedInstance().createSearchPerformer()

    init(searchInfo: JRSDKSearchInfo) {
        self.searchInfo = searchInfo
        super.init()
    }

    func handleLoad(view: ASTWaitingScreenViewProtocol) {
        self.view = view
        view.update(title: JRSearchInfoUtils.formattedIatasAndDatesExcludeYearComponent(for: searchInfo))
        view.animateProgress(duration: kJRSDKSearchPerformerAverageSearchTime)
        view.startAnimating()
        view.updateInfo(text: NSLS("JR_WAITING_TITLE"), range: NSRange())
        if ShowAppodealAds() {
            view.showAppodealAdvertisement()
        }
        if ShowAviasalesAds() {
            view.showAviasalesAdvertisement(searchInfo: searchInfo)
            requestSearchResultsAviasalesAdvertisement()
        }
        performSearch()
    }

    func handleUnload() {
        searchPerformer.terminateSearch()
    }

    func handleError() {
        view?.pop()
    }
}

fileprivate extension ASTWaitingScreenPresenter {

    func performSearch() {

        searchPerformer.delegate = self
        searchPerformer.performSearch(with: searchInfo, includeResultsInEnglish: true)
    }

    func requestSearchResultsAviasalesAdvertisement() {
        JRAdvertisementManager.sharedInstance().loadAndCacheAviasalesAdView(with: searchInfo)
    }

    func updateInfo(searchResult: JRSDKSearchResult) {

        guard let bestPrice = searchResult.bestPrice else {
            return
        }

        let count = searchResult.tickets.count
        let format = NSLSP("JR_FILTER_FLIGHTS_FOUND_MIN_PRICE", Float(count))
        let price = JRPriceUtils.formattedPrice(inUserCurrency: bestPrice).trimmingCharacters(in: .whitespaces)
        let string = String(format: format, count, price).trimmingCharacters(in: .whitespaces)
        let range = (string as NSString).localizedStandardRange(of: price)

        view?.updateInfo(text: string, range: range)
    }

    func description(from error: NSError) -> String {

        let result: String

        switch error.code {
        case JRSDKServerAPIError.searchNoTickets.rawValue:
            result = NSLS("JR_WAITING_ERROR_NOT_FOUND_MESSAGE")
        case JRSDKServerAPIError.connectionFailed.rawValue:
            result = NSLS("JR_WAITING_ERROR_CONNECTION_ERROR")
        default:
            result = NSLS("JR_WAITING_ERROR_NOT_AVALIBLE_MESSAGE")
        }

        return result
    }
}

extension ASTWaitingScreenPresenter: JRSDKSearchPerformerDelegate {

    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFindSomeTickets newTickets: JRSDKSearchResultsChunk!, in searchInfo: JRSDKSearchInfo!, temporaryResult: JRSDKSearchResult!, temporaryMetropolitanResult: JRSDKSearchResult!) {
        updateInfo(searchResult: temporaryResult)
    }

    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFinishRegularSearch searchInfo: JRSDKSearchInfo!, with result: JRSDKSearchResult!, andMetropolitanResult metropolitanResult: JRSDKSearchResult!) {

        guard  let result = result, let metropolitanResult = metropolitanResult else {
            return
        }

        let searchResult = result.tickets.count == 0 ? metropolitanResult : result
        view?.showSearchResults(searchResult: searchResult, searchInfo: searchInfo)
    }

    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFinalizeSearchWith searchInfo: JRSDKSearchInfo!, error: Error!) {
        // required in protocol
    }

    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFailSearchWithError error: Error!) {
        view?.showError(title: NSLS("JR_ERROR_TITLE"), message: description(from: error as NSError), cancel: NSLS("JR_OK_BUTTON"))
    }
}
