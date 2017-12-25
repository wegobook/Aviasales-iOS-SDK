//
//  InteractionManager.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 23/03/2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
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

    static let shared = InteractionManager()

    private var searchHotelsInfo: SearchHotelsInfo?

    var isCityReadyForSearchHotels: Bool {
        return searchHotelsInfo?.city != nil
    }

    private var savedHLSearchInfo: HLSearchInfo?
    private var savedDestination: JRSDKAirport?

    lazy private var geoLoader: AviasalesAirportsGeoSearchPerformer = AviasalesAirportsGeoSearchPerformer(delegate: self)

    weak var ticketsSearchForm: HotelsSearchDelegate?
    weak var hotelsSearchForm: TicketsSearchDelegate?

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
        geoLoader.searchAirportsNearLatitude(city.latitude, longitude: city.longitude)
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
