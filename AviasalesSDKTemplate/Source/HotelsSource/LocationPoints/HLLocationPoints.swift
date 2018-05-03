import CoreLocation

class HLCityAndNearbyPoint: HDKLocationPoint {

    let city: HDKCity

    init(name: String, location: CLLocation, city: HDKCity) {
        self.city = city
        super.init(name: name, location: location, category: HDKLocationPointCategory.kCityCenter)
    }

    required init(from other: Any) {
        guard let other = other as? HLCityAndNearbyPoint else {
            fatalError()
        }

        city = other.city
        super.init(from: other)
    }

    required init?(coder aDecoder: NSCoder) {
        guard let city = aDecoder.decodeObject(forKey: "city") as? HDKCity else {
            return nil
        }
        self.city = city
        super.init(coder: aDecoder)
    }

    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(city, forKey: "city")
    }

    override var actionCardDescription: String {
        return String(format: NSLS("HL_LOC_ACTION_CARD_DISTANCE_CITY_AND_NEARBY"), city.name ?? "")
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? HLCityAndNearbyPoint else { return false }
        if city != other.city {
            return false
        }
        return super.isEqual(object)
    }
}

class HLCustomLocationPoint: HDKLocationPoint {

    override init(name: String, location: CLLocation) {
        super.init(name: name, location: location, category: HDKLocationPointCategory.kCustomLocation)
    }

    required init(from other: Any) {
        super.init(from: other)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var actionCardDescription: String {
        return NSLS("HL_LOC_ACTION_CARD_DISTANCE_CUSTOM_SEARCH_POINT_TITLE")
    }
}

class HLUserLocationPoint: HDKLocationPoint {
    init(location: CLLocation) {
        super.init(name: NSLS("HL_LOC_FILTERS_POINT_MY_LOCATION_TEXT"), location: location, category: HDKLocationPointCategory.kUserLocation)
    }

    required init(from other: Any) {
        super.init(from: other)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var actionCardDescription: String {
        return NSLS("HL_LOC_ACTION_CARD_DISTANCE_USER_TITLE")
    }
}

class HLGenericCategoryLocationPoint: HDKLocationPoint {
    init(category: String) {
        super.init(name: HLGenericCategoryLocationPoint.name(for: category),
                   location: CLLocation(latitude: 0, longitude: 0),
                   category: category)
    }

    required init(from other: Any) {
        super.init(from: other)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var actionCardDescription: String {
        switch category {
            case HDKLocationPointCategory.kBeach:
                return NSLS("HL_LOC_ACTION_CARD_DISTANCE_BEACH_TITLE")
            case HDKLocationPointCategory.kSkilift:
                return NSLS("HL_LOC_ACTION_CARD_DISTANCE_SKILIFT_TITLE")
            default:
                assertionFailure()
                return ""
        }
    }

    private static func name(for category: String) -> String {
        switch category {
            case HDKLocationPointCategory.kBeach:
                return NSLS("HL_LOC_FILTERS_POINT_ANY_BEACH_TEXT")
            case HDKLocationPointCategory.kSkilift:
                return NSLS("HL_LOC_FILTERS_POINT_ANY_SKILIFT_TEXT")
            case HDKLocationPointCategory.kMetroStation:
                return NSLS("HL_LOC_FILTERS_POINT_ANY_METRO_TEXT")
            default:
                return ""
        }
    }
}

@objcMembers
class HLCityLocationPoint: HDKLocationPoint {
    let cityName: String?

    init(city: HDKCity) {
        let location = CLLocation(latitude: city.latitude, longitude: city.longitude)
        cityName = city.name
        super.init(name: NSLS("HL_LOC_FILTERS_POINT_CITY_CENTER_TEXT"), location: location, category: HDKLocationPointCategory.kCityCenter)
    }

    required init(from other: Any) {
        guard let other = other as? HLCityLocationPoint else {
            fatalError()
        }

        cityName = other.cityName
        super.init(from: other)
    }

    required init?(coder aDecoder: NSCoder) {
        cityName = aDecoder.decodeObject(forKey: "cityName") as? String
        super.init(coder: aDecoder)
    }

    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(cityName, forKey: "cityName")
    }

    override var actionCardDescription: String {
        return NSLS("HL_LOC_ACTION_CARD_DISTANCE_CENTER_TITLE")
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? HLCityLocationPoint else { return false }
        if cityName != other.cityName {
            return false
        }
        return super.isEqual(object)
    }
}

class HLAirportLocationPoint: HDKLocationPoint {
    override init(name: String, location: CLLocation) {
        super.init(name: name, location: location, category: HDKLocationPointCategory.kAirport)
    }

    required init(from other: Any) {
        super.init(from: other)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var actionCardDescription: String {
        return String(format: "%@%@", NSLS("HL_LOC_ACTION_CARD_DISTANCE_FROM_TITLE"), name)
    }
}
