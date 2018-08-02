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
    func showAdvertisement()
    func showSearchResults(searchResult: JRSDKSearchResult, searchInfo: JRSDKSearchInfo)
    func showError(title: String, message: String, cancel: String)
    func pop()
}

class ASTWaitingScreenPresenter: NSObject {

    weak var view: ASTWaitingScreenViewProtocol?

    private let searchInfo: JRSDKSearchInfo
    private let searchPerformer = AviasalesSDK.sharedInstance().createSearchPerformer()

    private var showErrorAction: (() -> Void)?
    private var canShowError = true {
        didSet {
            if canShowError {
                showErrorAction?()
                showErrorAction = nil
            }
        }
    }

    init(searchInfo: JRSDKSearchInfo) {
        self.searchInfo = searchInfo
        super.init()
    }

    func handleLoad(view: ASTWaitingScreenViewProtocol) {
        self.view = view
        view.showAdvertisement()
        view.update(title: JRSearchInfoUtils.formattedIatasAndDatesExcludeYearComponent(for: searchInfo))
        view.animateProgress(duration: kJRSDKSearchPerformerAverageSearchTime)
        view.startAnimating()
        view.updateInfo(text: NSLS("JR_WAITING_TITLE"), range: NSRange())
        performSearch()
        AviasalesAdManager.shared.loadAdView(for: searchInfo)
        PriceCalendarManager.shared.prepareLoader(with: searchInfo)
    }

    func handleShowAdvertisement() {
        canShowError = false
    }

    func handleHideAdvertisement() {
        canShowError = true
    }

    func handleUnload() {
        searchPerformer.terminateSearch()
    }

    func handleError() {
        view?.pop()
    }
}

private extension ASTWaitingScreenPresenter {

    func performSearch() {
        AviasalesSDK.sharedInstance().updateCurrencyCode(CurrencyManager.shared.currency.code.lowercased())
        searchPerformer.delegate = self
        searchPerformer.performSearch(with: searchInfo, includeResultsInEnglish: true)
    }

    func handle(_ temporaryResult: JRSDKSearchResult) {

        guard let bestPrice = temporaryResult.bestPrice else {
            return
        }

        let count = temporaryResult.tickets.count
        let format = NSLSP("JR_FILTER_FLIGHTS_FOUND_MIN_PRICE", Float(count))
        let price = bestPrice.formattedPriceinUserCurrency()
        let string = String(format: format, count, price)
        let range = (string as NSString).localizedStandardRange(of: price)

        view?.updateInfo(text: string, range: range)
    }

    func filter(searchResult: JRSDKSearchResult, by avialableAirlines: [String]) -> JRSDKSearchResult? {

        if avialableAirlines.count == 0 {
            return searchResult
        }

       let tickets = NSOrderedSetSequence<JRSDKTicket>(orderedSet: searchResult.tickets).filter { (ticket) -> Bool in
            let segments = NSOrderedSetSequence<JRSDKFlightSegment>(orderedSet: ticket.flightSegments)
            return segments.count == segments.filter({ (segment) -> Bool in
                let flights = NSOrderedSetSequence<JRSDKFlight>(orderedSet: segment.flights)
                return flights.count == flights.filter({ (flight) -> Bool in
                    return avialableAirlines.contains(flight.airline.iata)
                }).count
            }).count
        }

        let searchResultBuilder = JRSDKSearchResultBuilder()
        searchResultBuilder.searchResultInfo = searchResult.searchResultInfo
        searchResultBuilder.tickets = NSOrderedSet(array: tickets)
        searchResultBuilder.bestPrice = searchResult.bestPrice

        return searchResultBuilder.build()
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

    func show(errorMessage: String) {

        let showErrorAction: (() -> Void)? = { [weak self] in
            self?.view?.showError(title: NSLS("JR_ERROR_TITLE"), message: errorMessage, cancel: NSLS("JR_OK_BUTTON"))
        }

        if canShowError {
            showErrorAction?()
        } else {
            self.showErrorAction = showErrorAction
        }
    }
}

extension ASTWaitingScreenPresenter: JRSDKSearchPerformerDelegate {

    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFindSomeTickets newTickets: JRSDKSearchResultsChunk!, in searchInfo: JRSDKSearchInfo!, temporaryResult: JRSDKSearchResult!, temporaryMetropolitanResult: JRSDKSearchResult!) {
        if ConfigManager.shared.availableAirlines.count == 0 {
            handle(temporaryResult)
        }
    }

    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFinishRegularSearch searchInfo: JRSDKSearchInfo!, with result: JRSDKSearchResult!, andMetropolitanResult metropolitanResult: JRSDKSearchResult!) {

        guard  let result = result, let metropolitanResult = metropolitanResult else {
            return
        }

        let searchResult = result.tickets.count == 0 ? metropolitanResult : result

        if let filteredSearchResult = filter(searchResult: searchResult, by: ConfigManager.shared.availableAirlines), filteredSearchResult.tickets.count > 0 {
            view?.showSearchResults(searchResult: filteredSearchResult, searchInfo: searchInfo)
        } else {
            show(errorMessage: NSLS("JR_WAITING_ERROR_NOT_FOUND_MESSAGE"))
        }
    }

    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFinalizeSearchWith searchInfo: JRSDKSearchInfo!, error: Error!) {
        // required in protocol
    }

    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFailSearchWithError error: Error!) {
        show(errorMessage: description(from: error as NSError))
    }
}
