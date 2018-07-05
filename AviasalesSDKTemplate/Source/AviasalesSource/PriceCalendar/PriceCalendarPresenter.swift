//
//  PriceCalendarPresenter.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 12.02.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

enum PriceCalendarCellModelType {
    case average
    case direct
    case result
    case card
}

protocol PriceCalendarCellModelProtocol {
    var type: PriceCalendarCellModelType { get }
}

struct PriceCalendarAverageCellModel: PriceCalendarCellModelProtocol {

    struct PriceInfo {
        let price: String?
        let text: String?
    }

    let type = PriceCalendarCellModelType.average
    let text: String?
    let notDirectPriceInfo: PriceInfo?
    let directPriceInfo: PriceInfo?
}

struct PriceCalendarDirectCellModel: PriceCalendarCellModelProtocol {
    let type = PriceCalendarCellModelType.direct
    let info: String?
    let isOn: Bool
}

struct PriceCalendarResultCellModel: PriceCalendarCellModelProtocol {
    let type = PriceCalendarCellModelType.result
    let departureDate: Date?
    let returnDate: Date?
    let cheapest: String?
    let price: String?
    let dates: String?
}

struct PriceCalendarCardCellModel: PriceCalendarCellModelProtocol {
    let type = PriceCalendarCellModelType.card
    let viewModel: ActionCardViewModel
}

protocol PriceCalendarViewProtocol: class {
    func set(title: String)
    func showLoading()
    func hideLoading()
    func set(cellModels: [PriceCalendarCellModelProtocol])
    func showWaiting(with searchInfo: JRSDKSearchInfo)
    func showDatePicker(with date: Date)
}

class PriceCalendarPresenter {

    fileprivate weak var view: PriceCalendarViewProtocol?

    fileprivate let searchInfo: JRSDKSearchInfo

    fileprivate var shouldShowLoading = true

    fileprivate var avgDirectPrice: NSNumber? {
        guard let loader = PriceCalendarManager.shared.loader else {
            return nil
        }
        return loader.avgDirectPrice(inMonthOf: loader.selectedDeparture.date())
    }

    fileprivate var avgNotDirectPrice: NSNumber? {
        guard let loader = PriceCalendarManager.shared.loader else {
            return nil
        }
        return loader.avgNotDirectPrice(inMonthOf: loader.selectedDeparture.date())
    }

    fileprivate var isAvgDirectPriceValid: Bool {
        if let price = avgDirectPrice, price.floatValue > 0 {
            return true
        } else {
            return false
        }
    }

    fileprivate var isAvgNotDirectPriceValid: Bool {
        if let price = avgNotDirectPrice, price.floatValue > 0 {
            return true
        } else {
            return false
        }
    }

    init(searchInfo: JRSDKSearchInfo) {
        self.searchInfo = searchInfo
        startObservingNotifications()
    }

    deinit {
        stopObservingNotifications()
    }

    func attach(_ view: PriceCalendarViewProtocol) {
        self.view = view
        view.set(title: buildTitle())
        view.set(cellModels: buildCellModels())
    }

    func directSwitch() {
        let onlyDirect = PriceCalendarManager.shared.loader?.onlyDirect ?? false
        PriceCalendarManager.shared.loader?.onlyDirect = !onlyDirect
    }

    func select(_ cellModel: PriceCalendarCellModelProtocol) {
        switch cellModel.type {
        case .direct, .card, .average:
            return
        case .result:
            handle(select: cellModel as! PriceCalendarResultCellModel)
        }
    }

    func returnDate() {
        guard let date = PriceCalendarManager.shared.loader?.selectedDeparture.date() else {
            return
        }
        view?.showDatePicker(with: date)
    }

    func search(departureDate: Date?, returnDate: Date?) {
        initiateSearch(departureDate: departureDate, returnDate: returnDate)
    }
}

private extension PriceCalendarPresenter {

    func startObservingNotifications() {
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: JRSDKPriceCalendarLoaderStartLoadingNotification), object: nil, queue: nil) { [weak self] (_) in
            self?.handleStartLoading()
        }
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: JRSDKPriceCalendarLoaderStartLoadingDatePricesNotification), object: nil, queue: nil) { [weak self] (_) in
            self?.handleStartLoading()
        }
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: JRSDKPriceCalendarLoaderEndLoadingNotification), object: nil, queue: nil) { [weak self] (_) in
            self?.handleEndLoading()
        }
    }

    func stopObservingNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension PriceCalendarPresenter {

    func handle(select cellModel: PriceCalendarResultCellModel) {
        initiateSearch(departureDate: cellModel.departureDate, returnDate: cellModel.returnDate)
    }

    func initiateSearch(departureDate: Date?, returnDate: Date?) {

        let firstTravelSegment = searchInfo.travelSegments.firstObject as? JRSDKTravelSegment

        var travelSegments = [JRSDKTravelSegment]()

        if let directTravelSegment = buildTravelSegment(departure: departureDate, origin: firstTravelSegment?.originAirport, destination: firstTravelSegment?.destinationAirport) {
            travelSegments.append(directTravelSegment)
        }

        if let returnTravelSegment = buildTravelSegment(departure: returnDate, origin: firstTravelSegment?.destinationAirport, destination: firstTravelSegment?.originAirport) {
            travelSegments.append(returnTravelSegment)
        }

        let builder = JRSDKSearchInfoBuilder(searchInfoToCopy: searchInfo)
        builder.travelSegments = NSOrderedSet(array: travelSegments)

        if let searchInfo = builder.build() {
            shouldShowLoading = false
            view?.showWaiting(with: searchInfo)
            SearchInfoBuilderStorage.shared.updateStorage(simpleSearchInfo: searchInfo)
        }
    }

    func buildTravelSegment(departure: Date?, origin: JRSDKAirport?, destination: JRSDKAirport?) -> JRSDKTravelSegment? {
        let builder = JRSDKTravelSegmentBuilder()
        builder.departureDate = departure
        builder.originAirport = origin
        builder.destinationAirport = destination
        return builder.build()
    }
}

private extension PriceCalendarPresenter {

    func buildTitle() -> String {
        guard let firstTravelSegment = PriceCalendarManager.shared.loader?.searchInfo.travelSegments.firstObject as? JRSDKTravelSegment else {
            return NSLS("SEARCH_RESULTS_PRICE_CALENDAR_VIEW_TITLE")
        }
        return String(format: NSLS("PRICE_CALENDAR_TITLE_FORMAT").formatAccordingToTextDirection(), firstTravelSegment.originAirport.iata, firstTravelSegment.destinationAirport.iata)
    }

    func handleStartLoading() {
        if shouldShowLoading {
            view?.showLoading()
        }
    }

    func handleEndLoading() {
        view?.hideLoading()
        view?.set(cellModels: buildCellModels())
    }

    func buildCellModels() -> [PriceCalendarCellModelProtocol] {
        var cellModels = [PriceCalendarCellModelProtocol]()
        if isAvgDirectPriceValid || isAvgNotDirectPriceValid {
            cellModels.append(buildAverageCellModel())
        }
        if PriceCalendarManager.shared.loader?.hasDirectPrices() ?? false {
            cellModels.append(buildDirectCellModel())
        }
        cellModels.append(contentsOf: buildResultCellModels())
        if searchInfo.travelSegments.count > 1 {
            cellModels.append(buildCardCellModel())
        }
        return cellModels
    }

    func buildDirectCellModel() -> PriceCalendarCellModelProtocol {
        let text = NSLS("PRICE_CALENDAR_DIRECT_CELL_TEXT")
        let onlyDirect = PriceCalendarManager.shared.loader?.onlyDirect ?? false
        return PriceCalendarDirectCellModel(info: text, isOn: onlyDirect)
    }

    func buildAverageCellModel() -> PriceCalendarCellModelProtocol {
        let text = NSLS("PRICE_CALENDAR_AVERAGE_CELL_TEXT")
        let directPriceInfo = isAvgDirectPriceValid ? PriceCalendarAverageCellModel.PriceInfo(price: formatPriceValue(avgDirectPrice), text: NSLS("PRICE_CALENDAR_AVERAGE_CELL_DIRECT_TEXT")) : nil
        let notDirectPriceInfo = isAvgNotDirectPriceValid ? PriceCalendarAverageCellModel.PriceInfo(price: formatPriceValue(avgNotDirectPrice), text: NSLS("PRICE_CALENDAR_AVERAGE_CELL_NOT_DIRECT_TEXT")) : nil
        return PriceCalendarAverageCellModel(text: text, notDirectPriceInfo: notDirectPriceInfo, directPriceInfo: directPriceInfo)
    }

    func formatPriceValue(_ value: NSNumber?) -> String {
        let noPriceString = "-"
        guard let floatValue = value?.floatValue else {
            return noPriceString
        }
        return JRSDKPrice.price(currency: RUB_CURRENCY, value: floatValue)?.formattedPriceinUserCurrency() ?? noPriceString
    }

    func buildResultCellModels() -> [PriceCalendarCellModelProtocol] {
        guard let deraprture = PriceCalendarManager.shared.loader?.selectedDeparture else {
            return [PriceCalendarCellModelProtocol]()
        }
        return deraprture.prices().sorted(by: { $0.value.compare($1.value) == .orderedAscending }).enumerated().map {
            buildResultCellModel(first: $0.0 == 0, departure: deraprture, key: $0.1.key, value: $0.1.value)
        }
    }

    func buildResultCellModel(first: Bool, departure: JRSDKPriceCalendarDeparture, key: String, value: NSNumber) -> PriceCalendarResultCellModel {

        let cheapest = first ? NSLS("PRICE_CALENDAR_RESULT_CELL_CHEAPEST") : nil

        let format = NSLS("PRICE_CALENDAR_PRICE_VIEW_TEXT")
        let price = JRSDKPrice.price(currency: RUB_CURRENCY, value: value.floatValue)?.formattedPriceinUserCurrency() ?? ""

        let departureDate = departure.date()
        let returnDate = searchInfo.travelSegments.count > 1 ? JRSDKPriceCalendarLoader.date(fromKey: key) : nil

        let dates = datesString(departureDate: departureDate, returnDate: returnDate)

        return PriceCalendarResultCellModel(departureDate: departureDate, returnDate: returnDate, cheapest: cheapest, price: String(format: format, price), dates: dates)
    }

    func datesString(departureDate: Date?, returnDate: Date?) -> String? {
        guard let departureDate = departureDate else {
            return nil
        }
        var result = DateUtil.dayMonthWeekdayString(from: departureDate)!
        if let returnDate = returnDate {
            result.append(" - \(DateUtil.dayMonthWeekdayString(from: returnDate)!)")
        }
        return result
    }

    func buildCardCellModel() -> PriceCalendarCellModelProtocol {
        let cardViewModel = ActionCardViewModel(title: NSLS("PRICE_CALENDAR_ACTION_CARD_TITLE"), text: NSLS("PRICE_CALENDAR_ACTION_CARD_TEXT"), button: NSLS("PRICE_CALENDAR_ACTION_CARD_BUTTON"))
        return PriceCalendarCardCellModel(viewModel: cardViewModel)
    }
}
