import CoreLocation

class HLSearchCityCenterLocationPoint: HDKSearchLocationPoint {
    init(city: HDKCity, nearbyCities: [HDKCity]) {
        let location = CLLocation(latitude: city.latitude, longitude: city.longitude)
        super.init(location: location, title: "")
        self.city = city
        self.nearbyCities = nearbyCities
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class HLCustomSearchLocationPoint: HDKSearchLocationPoint {
    init(location: CLLocation, nearbyCities: [HDKCity]) {
        super.init(location: location, title: NSLS("HL_LOC_POINT_ON_MAP_TEXT"))
        self.nearbyCities = nearbyCities
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

@objcMembers
class HLSearchUserLocationPoint: HDKSearchLocationPoint {
    init(location: CLLocation, nearbyCities: [HDKCity]) {
        super.init(location: location, title: NSLS("HL_LOC_FILTERS_POINT_MY_LOCATION_TEXT"))
        self.nearbyCities = nearbyCities
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func forCurrentLocation() -> HLSearchUserLocationPoint? {
        if let location = HLLocationManager.shared().location() {
            return HLSearchUserLocationPoint(location: location, nearbyCities: HLNearbyCitiesDetector.shared().nearbyCities ?? [])
        }

        return nil
    }
}

@objcMembers
class HLSearchAirportLocationPoint: HDKSearchLocationPoint {
    let airport: HDKAirport

    init(airport: HDKAirport) {
        self.airport = airport
        let location = CLLocation(latitude: airport.latitude, longitude: airport.longitude)
        super.init(location: location, title: airport.name)
    }

    required init?(coder: NSCoder) {
        guard let airport = coder.decodeObject(forKey: "airport") as? HDKAirport else { return nil }
        self.airport = airport
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(airport, forKey: "airport")
        super.encode(with: coder)
    }
}
