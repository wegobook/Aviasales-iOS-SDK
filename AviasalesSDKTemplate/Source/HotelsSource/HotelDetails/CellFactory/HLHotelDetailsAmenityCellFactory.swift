struct AmenityConst {
    static let depositKey = "deposit"
    static let cleaningKey = "cleaning"
    static let privateBathroomKey = "private_bathroom"
    static let sharedBathroomKey = "shared_bathroom"

    static let slugKey = "slug"
    static let priceKey = "price"
}

class HLHotelDetailsAmenityCellFactory: HLHotelDetailsCellFactory {

    static let kMaxAmenitiesCells = 5
    static let kDefaultAmenityIconName = "amenitiesDefault"

    fileprivate static let amenityImageNames: [String: String] = [
        "free_parking": "amenitiesParking",
        "parking" : "amenitiesParking",
        "24_hours_front_desk_service" : "24hoursAmenitiesIcon",
        "low_mobility_guests_welcome" : "disabledFriendly",
        "restaurant_cafe" : "amenitiesRestaurant",
        "bar" : "barAmenitiesIcon",
        "business_centre" : "centerAmenitiesIcon",
        "laundry_service" : "amenitiesLaundry",
        "concierge_service" : "conciergeAmenitiesIcon",
        "wi-fi_in_public_areas" : "amenitiesInternet",
        "gym" : "amenitiesFitness",
        "spa" : "spaAmenitiesIcon",
        "pets_allowed" : "amenitiesPets",
        "swimming_pool" : "amenitiesPool",
        "lgbt_friendly" : "gayFriendlyAmenitiesIcon",
        "medical_service" : "medicalServiceAmenitiesIcon",
        "babysitting" : "babysittingAmenitiesIcon",
        "children_care_activities" : "childrenActivitiesAmenitiesIcon",
        "animation" : "animationAmenitiesIcon",

        "bathtub" : "amenitiesTube",
        "shower" : "showerAmenitiesIcon",
        "tv" : "amenitiesTV",
        "air_conditioning" : "amenitiesSnow",
        "safe_box" : "safeAmenitiesIcon",
        "mini_bar" : "minibarAmenitiesIcon",
        "hairdryer" : "amenitiesHairdryer",
        "coffee_tea" : "optionsBreakfast",
        "bathrobes" : "robeAmenitiesIcon",
        "daily_housekeeping" : "cleaningAmenitiesIcon",
        "connecting_rooms" : "doorAmenitiesIcon",
        "smoking_room" : "amenitiesSmoking",
        "wi-fi_in_rooms" : "amenitiesInternet",
        AmenityConst.privateBathroomKey : "amenitiesPrivateBathroom"
        ]

    private static let amenitiesBlackList = [AmenityConst.depositKey, AmenityConst.cleaningKey, AmenityConst.sharedBathroomKey]

    class func createAmenitiesInRoom(_ hotel: HDKHotel, tableView: UITableView) -> [TableItem] {
        return createAmenitiesFromArray(hotel.roomAmenities(), tableView: tableView)
    }

    class func createAmenitiesInHotel(_ hotel: HDKHotel, tableView: UITableView) -> [TableItem] {
        return createAmenitiesFromArray(hotel.hotelAmenities(), tableView: tableView)
    }

    fileprivate class func createAmenitiesFromArray(_ array: [HDKAmenity], tableView: UITableView) -> [TableItem] {
        var flattenAmenities: [NamedHotelDetailsItem] = []
        for amenity in array {
            let key = amenity.slug
            if !amenitiesBlackList.contains(key) && !amenity.name.isEmpty {

                let keyWithPrice: String
                if amenity.isFree {
                    keyWithPrice = "free_" + key
                } else {
                    keyWithPrice = key
                }

                let itemImageKey = amenityImageNames[keyWithPrice] != nil ? keyWithPrice : key
                let image = amenityIconWithKey(itemImageKey as NSString)

                let item = AmenityItem(name: amenity.name, image: image)
                flattenAmenities.append(item)
            }
        }

        return HLTwoColumnCellsDataSource(flattenedItems: flattenAmenities, cellWidth: tableView.bounds.width, canFillHalfScreen: HLHotelDetailsFeaturesCell.canFillHalfScreen).splitItemsLongAtBottom()
    }

    class func amenityIconWithKey(_ key: NSString) -> UIImage {
        if let imageName = amenityImageNames[key as String], let image = UIImage(named: imageName) {
            return image
        } else {
            return UIImage(named: kDefaultAmenityIconName)!
        }
    }
}
