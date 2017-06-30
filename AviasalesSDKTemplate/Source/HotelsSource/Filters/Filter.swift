struct AmenityShortConst {
    static let restaurant = "0"
    static let parking = "1"
    static let pets = "3"
    static let tv = "4"                 // swiftlint:disable:this variable_name
    static let laundry = "5"
    static let airConditioning = "6"
    static let pool = "8"
    static let fitness = "9"
    static let hairDryer = "12"
    static let safeBox = "14"
    static let childrenActivities = "15|16"
}

@objc class Filter: HLFilter {

    var availablePropertyTypes: Set<HLHotelPropertyType> = []
    var stars: Set<Int> = []

    override func canDropFilters() -> Bool {
        return (availablePropertyTypes.count > 0) ||
            stars.count > 0 ||
            super.canDropFilters()
    }

    override func dropCommonValues() {
        availablePropertyTypes = []
        stars = []
        super.dropCommonValues()
    }

    func applyParams(_ filter: Filter!) {
        stars = filter.stars
        availablePropertyTypes = filter.availablePropertyTypes
        super.applyParams(filter)
    }

    var filterChildrenActivities: Bool {
        return amenities.contains(AmenityShortConst.childrenActivities)
    }

    var filterSafeBox: Bool {
        return amenities.contains(AmenityShortConst.safeBox)
    }

    var filterRoomWifi: Bool {
        return options.contains(RoomOptionConsts.kRoomWifiOptionKey)
    }

    var filterAirConditioning: Bool {
        return amenities.contains(AmenityShortConst.airConditioning)
    }

    var filterHairdryer: Bool {
        return amenities.contains(AmenityShortConst.hairDryer)
    }

    var filterTV: Bool {
        return amenities.contains(AmenityShortConst.tv)
    }

    var filterNiceView: Bool {
        return options.contains(RoomOptionConsts.kNiceViewOptionKey)
    }

    var filterSmoking: Bool {
        return options.contains(RoomOptionConsts.kSmokingOptionKey)
    }

    var filterParking: Bool {
        return amenities.contains(AmenityShortConst.parking)
    }

    var filterRestaurant: Bool {
        return amenities.contains(AmenityShortConst.restaurant)
    }

    var filterPool: Bool {
        return amenities.contains(AmenityShortConst.pool)
    }

    var filterFitness: Bool {
        return amenities.contains(AmenityShortConst.fitness)
    }

    var filterPets: Bool {
        return amenities.contains(AmenityShortConst.pets)
    }

    var filterLaundry: Bool {
        return amenities.contains(AmenityShortConst.laundry)
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone)
        if let filterCopy = copy as? Filter {
            filterCopy.stars = stars
            filterCopy.availablePropertyTypes = availablePropertyTypes
        }

        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let filterObject = object as? Filter else { return false }
        return (stars == filterObject.stars) && super.isEqual(filterObject)
    }

    func filter() {
        filterQueue.cancelAllOperations()
        let operation = HLFilteringOperation()
        operation.queuePriority = .normal
        operation.delegate = self
        operation.filter = self
        operation.variants = searchResult.variants

        filterQueue.addOperation(operation)
    }
}
