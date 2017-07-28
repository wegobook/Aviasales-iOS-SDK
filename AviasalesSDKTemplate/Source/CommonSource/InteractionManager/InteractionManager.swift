//
//  InteractionManager.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 23/03/2017.
//  Copyright © 2017 Go Travel Un LImited. All rights reserved.
//

@objc protocol HotelsSearchDelegate: NSObjectProtocol {
    func updateSearchInfo(destination: JRSDKAirport, checkIn: Date, checkOut: Date, passengers: ASTPassengersInfo)
}

@objc protocol TicketsSearchDelegate: NSObjectProtocol {
    func updateSearchInfo(city: HDKCity, adults: UInt, checkIn: Date, checkOut: Date)
}

class InteractionManager: NSObject, AviasalesAirportsGeoSearchPerformerDelegate {

    private struct SearchHotelsInfo {
        let checkIn: Date
        let checkOut: Date
        let adults: UInt
        var city: HDKCity?

        init(checkIn: Date, checkOut: Date, adults: UInt) {
            self.checkIn = checkIn
            self.checkOut = checkOut
            self.adults = adults
        }
    }

    private let kSavedCurrencyKey = "kSavedCurrencyKey"

    static let shared = InteractionManager()

    private var searchHotelsInfo: SearchHotelsInfo?

    var isCityReadyForSearchHotels: Bool {
        return searchHotelsInfo?.city != nil
    }

    private var savedHLSearchInfo: HLSearchInfo?
    private var savedDestination: JRSDKAirport?

    private var geoLoader: AviasalesAirportsGeoSearchPerformer!

    weak var ticketsSearchForm: HotelsSearchDelegate?
    weak var hotelsSearchForm: TicketsSearchDelegate?

    private(set) var currency: HDKCurrency = CurrencyManager.shared.defaultCurrency()

    override init() {
        super.init()
        if let savedCurrency = self.loadCurrency() {
            currency = savedCurrency
        } else {
            let currencyCode = Locale.current.currencyCode ?? ""
            currency = CurrencyManager.shared.getCurrency(withCode: currencyCode) ?? CurrencyManager.shared.defaultCurrency()
            saveCurrency(currency)
        }
        geoLoader = AviasalesAirportsGeoSearchPerformer(delegate: self)
    }

    // MARK: - Common

    func currencySelected(_ newCurrency: HDKCurrency) {
        currency = newCurrency
        saveCurrency(currency)
    }

    func saveCurrency(_ currency: HDKCurrency) {
        let data = NSKeyedArchiver.archivedData(withRootObject: currency)
        UserDefaults.standard.set(data, forKey: kSavedCurrencyKey)
    }

    func loadCurrency() -> HDKCurrency? {
        if let data = UserDefaults.standard.object(forKey: kSavedCurrencyKey) as? Data {
            let currency = NSKeyedUnarchiver.unarchiveObject(with: data)
            return currency as? HDKCurrency
        }
        return nil
    }

    // MARK: - Tickets

    func prepareSearchHotelsInfo(from searchInfo: JRSDKSearchInfo) {

        guard let firstTravelSegment = searchInfo.travelSegments.firstObject as? JRSDKTravelSegment, let lastTravelSegment = searchInfo.travelSegments.lastObject as? JRSDKTravelSegment else {
            return
        }

        let checkIn = firstTravelSegment.departureDate
        let checkOut: Date
        if firstTravelSegment != lastTravelSegment, DateUtil.dateIn30Days(firstTravelSegment.departureDate) > lastTravelSegment.departureDate {
            checkOut = lastTravelSegment.departureDate
        } else {
            checkOut = DateUtil.nextDay(for: checkIn)
        }
        searchHotelsInfo = SearchHotelsInfo(checkIn: checkIn, checkOut: checkOut, adults: 1)
        requestHDKCity(iata: firstTravelSegment.destinationAirport.iata)
    }

    func clearSearchHotelsInfo() {
        searchHotelsInfo = nil
    }

    private func requestHDKCity(iata: String) {
        ServiceLocator.shared.api.autocomplete(text: iata, limit: 1).promise().then { [weak self] (response) in
            self?.searchHotelsInfo?.city = response.cities.first
        }.catch { _ in }
    }

    func applySearchHotelsInfo() {
        guard let searchHotelsInfo = searchHotelsInfo, let city = searchHotelsInfo.city else {
            return
        }

        hotelsSearchForm?.updateSearchInfo(city: city, adults: searchHotelsInfo.adults, checkIn: searchHotelsInfo.checkIn, checkOut: searchHotelsInfo.checkOut)
    }

    // MARK: - Hotels

    func hotelsSearchFinished(_ searchInfo: HLSearchInfo) {
        guard let city = searchInfo.city ?? searchInfo.hotel?.city,
            (city.latitude != 0.0 || city.latitude != 0.0) else {
                return
        }
        self.savedHLSearchInfo = searchInfo
        geoLoader?.searchAirportsNearLatitude(city.latitude, longitude: city.longitude)
    }

    func applySavedTicketsSearchInfo() {
        if let airport = savedDestination, let searchInfo = savedHLSearchInfo {
            let passengers = ASTPassengersInfo(adults: searchInfo.adultsCount, children: 0, infants: 0, travelClass: .economy)
            ticketsSearchForm?.updateSearchInfo(destination: airport, checkIn: searchInfo.checkInDate!, checkOut: searchInfo.checkOutDate!, passengers: passengers)
            savedHLSearchInfo = nil
        }
        savedDestination = nil
        savedHLSearchInfo = nil
    }

    // MARK: - AviasalesAirportsGeoSearchPerformerDelegate

    func airportsGeoSearchPerformer(_ airportsSearchPerformer: AviasalesAirportsGeoSearchPerformer!, didFound locations: [JRSDKLocation]?) {
        let location = locations?.first(where: { (location) -> Bool in return location is JRSDKAirport })
        if let airport = location as? JRSDKAirport {
            savedDestination = airport
        }
    }
}
