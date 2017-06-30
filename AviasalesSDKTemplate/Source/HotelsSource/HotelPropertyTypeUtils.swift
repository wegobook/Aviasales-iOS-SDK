@objc enum HLHotelPropertyType: NSInteger {
    case unknown = 0
    case hotel = 1
    case apartHotel = 2
    case bedAndBreakfast = 3
    case apartment = 4
    case motel = 5
    case guesthouse = 6
    case hostel = 7
    case resort = 8
    case farm = 9
    case vacation = 10
    case lodge = 11
    case villa = 12
    case room = 13

    // swiftlint:disable:next cyclomatic_complexity
    func localizedValue() -> String? {
        switch self {
            case .unknown: return nil
            case .hotel: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_HOTEL")
            case .apartHotel: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_APART_HOTEL")
            case .bedAndBreakfast: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_BED_AND_BREAKFAST")
            case .apartment: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_APARTMENT")
            case .motel: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_MOTEL")
            case .guesthouse: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_GUESTHOUSE")
            case .hostel: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_HOSTEL")
            case .resort: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_RESORT")
            case .farm: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_FARM")
            case .vacation: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_VACATION")
            case .lodge: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_LODGE")
            case .villa: return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_VILLA")
            case .room : return NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_ROOM")
        }
    }

    static let wholePropertyValues: Set<HLHotelPropertyType> = [unknown, hotel, apartHotel, bedAndBreakfast, apartment, motel, guesthouse, hostel, resort, farm, vacation, lodge, villa]
    static let roomValues: Set<HLHotelPropertyType> = [room]
    static let apartmentValues: Set<HLHotelPropertyType> = [apartHotel, apartment, guesthouse, farm, vacation, villa]
    static let hotelValues: Set<HLHotelPropertyType> = [unknown, hotel, bedAndBreakfast, motel, resort, lodge]
    static let hostelValues: Set<HLHotelPropertyType> = [hostel]
}

class HotelPropertyTypeUtils: NSObject {

    class func localizedHotelPropertyType(_ hotel: HDKHotel) -> String? {
        let hotelPropertyEnum = HotelPropertyTypeUtils.hotelPropertyTypeEnum(hotel)

        return hotelPropertyEnum.localizedValue()
    }

    class func hotelPropertyType(_ hotel: HDKHotel) -> String {
        let types = ["Unknown", "Hotel", "Apart-hotel", "Bed&Breakfast", "Apartment", "Motel",
        "Guesthouse", "Hostel", "Resort", "Farm", "Vacation", "Lodge", "Villa", "Room"]

        return hotel.type < types.count ? types[hotel.type] : "Unknown"
    }

    class func hotelPropertyTypeEnum(_ hotel: HDKHotel) -> HLHotelPropertyType {
        return HLHotelPropertyType(rawValue: hotel.type) ?? .unknown
    }
}
