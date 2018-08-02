import HotellookSDK

@objc enum HLSearchInfoType: Int {
    case unknown
    case city
    case hotel
    case userLocation
    case cityCenterLocation
    case airport
    case customLocation
}

@objcMembers
class HLSearchInfo: HDKSearchInfo {

    private let kSearchDatesInPastLifetime: TimeInterval = 3 * 60 * 60
    private var shouldUpdateMinPriceOnChanges = false
    private var inDestinationSetterNow = false

    override var currency: HDKCurrency {
        didSet {
            postSearchInfoChangedNotification()
        }
    }

    override var city: HDKCity? {
        didSet {
            if city != nil && !inDestinationSetterNow {
                inDestinationSetterNow = true
                locationPoint = nil
                airport = nil
                inDestinationSetterNow = false
            }

            postSearchInfoChangedNotification()
        }
    }

    override var airport: HDKAirport? {
        didSet {
            if airport != nil && !inDestinationSetterNow {
                inDestinationSetterNow = true
                city = nil
                hotel = nil
                inDestinationSetterNow = false
            }
            postSearchInfoChangedNotification()
        }
    }

    override var locationPoint: HDKSearchLocationPoint? {
        didSet {
            if locationPoint != nil && !inDestinationSetterNow {
                inDestinationSetterNow = true
                city = nil
                hotel = nil
                inDestinationSetterNow = false
            }
            postSearchInfoChangedNotification()
        }
    }

    override var hotel: HDKHotel? {
        didSet {
            if hotel != nil && !inDestinationSetterNow {
                inDestinationSetterNow = true
                locationPoint = nil
                airport = nil
                inDestinationSetterNow = false
            }
            postSearchInfoChangedNotification()
        }
    }

    override var adultsCount: Int {
        didSet {
            postSearchInfoChangedNotification()
        }
    }

    override var kidAgesArray: [Int] {
        didSet {
            postSearchInfoChangedNotification()
        }
    }

    override var checkInDate: Date? {
        didSet {
            postSearchInfoChangedNotification()
        }
    }

    override var checkOutDate: Date? {
        didSet {
            postSearchInfoChangedNotification()
        }
    }

    static func defaultSearchInfo() -> HLSearchInfo {
        let currency = CurrencyManager.shared.currency

        let allowEnglishOTA = true
        let token = HDKTokenManager.mobileToken()

        let searchInfo = HLSearchInfo(currency: currency, allowEnglishOTA: allowEnglishOTA, token: token, adultsCount: 1)
        searchInfo.checkInDate = DateUtil.nextWeekend()
        searchInfo.checkOutDate = DateUtil.nextDay(for: searchInfo.checkInDate)

        searchInfo.updateExpiredDates()

        searchInfo.city = HLDefaultCitiesFactory.configCity() ?? HLDefaultCitiesFactory.defaultCity()

        return searchInfo
    }

    func update(withDict dict: [String: Any]) {

        let adults: Int = (dict["adults"] as? Int) ?? 0

        if adults > 0 && adults <= 4 {
            adultsCount = adults
            kidAgesArray = []
        }
    }

    func update(withSearchInfo other: HLSearchInfo) {
        token = other.token
        city = other.city
        locationPoint = other.locationPoint
        airport = other.airport
        adultsCount = other.adultsCount
        checkInDate = other.checkInDate
        checkOutDate = other.checkOutDate
        currency = other.currency
        shouldUpdateMinPriceOnChanges = other.shouldUpdateMinPriceOnChanges
        kidAgesArray = other.kidAgesArray
        hotel = other.hotel
        allowEnglishOTA = other.allowEnglishOTA
    }

    var searchInfoType: HLSearchInfoType {
        if locationPoint is HLSearchCityCenterLocationPoint {
            return .cityCenterLocation
        } else if locationPoint is HLCustomSearchLocationPoint {
            return .customLocation
        } else if locationPoint is HLSearchUserLocationPoint {
            return .userLocation
        } else if locationPoint is HLSearchAirportLocationPoint {
            return .airport
        } else if hotel != nil {
            return .hotel
        } else if city != nil {
            return .city
        } else {
            return .unknown
        }
    }

    var cityByCurrentSearchType: HDKCity? {
        switch searchInfoType {
        case .hotel:
            return hotel?.city
        case .city:
            return city
        case .cityCenterLocation:
            return locationPoint?.city
        case .userLocation, .customLocation, .airport:
            return locationPoint?.nearbyCities.first
        case .unknown:
            return nil
        }
    }

    var durationInDays: Int {
        guard let checkIn = checkInDate, let checkOut = checkOutDate else { return 0 }
        return DateUtil.hl_daysBetweenDate(checkIn, andOtherDate: checkOut)
    }

    func searchLocation() -> CLLocation? {
        switch searchInfoType {
        case .customLocation, .userLocation, .cityCenterLocation, .airport:
            return locationPoint?.location
        case .city:
            guard let lat = city?.latitude, let lon = city?.longitude else { return nil }
            return CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        case .hotel:
            guard let lat = hotel?.latitude, let lon = hotel?.longitude else { return nil }
            return CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        case .unknown:
            return nil
        }
    }

    func areDatesExpired() -> Bool {
        return isCheckInDateExpired() || isCheckOutDateExpired()
    }

    func readyToSearch() -> Bool {
        return adultsCount > 0 &&
            checkInDate != nil &&
            checkOutDate != nil &&
            (city?.cityId != nil || hotel?.hotelId != nil || locationPoint != nil)
    }

    func updateExpiredDates() {
        if isCheckInDateExpired() {
            checkInDate = DateUtil.today()
        }

        if isCheckOutDateExpired() {
            checkOutDate = DateUtil.nextDay(for: checkInDate)
        }
    }

    func isSearchByLocation() -> Bool {
        let searchType = searchInfoType
        return searchType == .customLocation ||
               searchType == .cityCenterLocation ||
               searchType == .userLocation ||
               searchType == .airport
    }

    private func isCheckInDateExpired() -> Bool {
        guard let checkIn = checkInDate else {
            return true
        }

        let todayDate = DateUtil.today()!
        let borderDate = DateUtil.borderDate()!
        let borderInterval = checkIn.timeIntervalSince(borderDate)
        let todayInterval = checkIn.timeIntervalSince(todayDate)

        let isBorderDateExpired = borderInterval < 0
        let isCheckInDateInPast = todayInterval < 0

        return isBorderDateExpired || isCheckInDateInPast
    }

    private func isCheckOutDateExpired() -> Bool {
        guard let checkOut = checkOutDate else {
            return true
        }

        let nextDay = DateUtil.nextDay(for: checkInDate)!
        let interval = checkOut.timeIntervalSince(nextDay)

        return interval < 0
    }

    private func postSearchInfoChangedNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: HL_SEARCHINFO_CHANGED), object: self)
    }
}
