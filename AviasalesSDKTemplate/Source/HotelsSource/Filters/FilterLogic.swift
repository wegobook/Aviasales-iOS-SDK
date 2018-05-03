@objcMembers
class FilterLogic: NSObject {

    static func doesVariantConformNameFilter(_ variant: HLResultVariant, filterString: String?) -> Bool {
        guard let searchString = filterString?.lowercased() else { return true }
        guard searchString.count > 0 else { return true }

        if let name = variant.hotel.name?.lowercased(), name.range(of: searchString) != nil {
            return true
        }
        if let englishName = variant.hotel.latinName?.lowercased(), englishName.range(of: searchString) != nil {
            return true
        }

        return false
    }

    static func doesVariantConformPropertyType(_ variant: HLResultVariant, filter: Filter) -> Bool {
        if filter.availablePropertyTypes.count == 0 {
            return true
        } else {
            let typeEnum = HotelPropertyTypeUtils.hotelPropertyTypeEnum(variant.hotel)

            return filter.availablePropertyTypes.contains(typeEnum)
        }
    }

    static func doesVariantConformStarsFilter(_ variant: HLResultVariant, filter: Filter) -> Bool {
        let star = variant.hotel.stars
        if filter.stars.count > 0 && !filter.stars.contains(star) {
            return false
        }

        return true
    }

    static func hotelWebsiteAgencyName() -> String {
        return NSLS("HL_LOC_FILTER_HOTEL_WEBSITE")
    }

    static func countHotelsAccordingToGates(_ variants: [HLResultVariant], hotelWebsiteString: String) -> [String: NSNumber] {
        var result: [String: NSNumber] = [:]

        for variant in variants {
            if let rooms = variant.roomsCopy() {
                var gates = Set<String>()
                for room in rooms {
                    if room.hasHotelWebsiteOption {
                        gates.insert(hotelWebsiteString)
                    } else {
                        gates.insert(room.gate.name ?? "")
                    }
                }
                for gate in gates {
                    let count = result[gate]?.intValue ?? 0
                    result[gate] = NSNumber(value: count + 1)
                }
            }
        }

        return result
    }

    @objc static func filterRoomsByAirConditioning(_ variant: HLResultVariant) -> [HDKRoom]? {
        let hotelAmenitiesValues: [String] = variant.hotel.amenitiesShort.compactMap { $0.value.slug }
        if hotelAmenitiesValues.contains(RoomOptionConsts.kHotelAirConditioningOptionKey) {
            return variant.filteredRooms.filter { !$0.hasFan }
        } else {
            return variant.filteredRooms.filter { (room) -> Bool in
                return room.hasAirConditioning
            }
        }
    }

    @objc static func filterRoomsBySharedBathroom(_ variant: HLResultVariant) -> [HDKRoom]? {
        let hotelAmenitiesValues: [String] = variant.hotel.amenitiesShort.compactMap { $0.value.slug }
        let hotelHasSharedBathroom = hotelAmenitiesValues.contains(RoomOptionConsts.kHotelSharedBathroomKey)
        return variant.filteredRooms.filter { (room) -> Bool in
            if room.hasSharedBathroom {
                return false
            }
            if room.hasPrivateBathroom {
                return true
            }
            if hotelHasSharedBathroom {
                return false
            }
            if room.isDormitory {
                return false
            }
            return true
        }
    }

    @objc static func filterRoomsByWifi(_ variant: HLResultVariant) -> [HDKRoom]? {
        let hotelAmenitiesValues: [String] = variant.hotel.amenitiesShort.compactMap { $0.value.slug }
        if hotelAmenitiesValues.contains(RoomOptionConsts.kHotelWifiInRoomOptionKey) {
            return variant.filteredRooms
        } else {
            return variant.filteredRooms.filter { (room) -> Bool in
                return room.hasWifi
            }
        }
    }

    @objc static func filterRoomsByDormitory(_ variant: HLResultVariant) -> [HDKRoom]? {
        return variant.filteredRooms.filter { (room) -> Bool in
            return !room.isDormitory
        }
    }

    static func filterRoomsByBreakfast(_ variant: HLResultVariant) -> [HDKRoom]? {
        return variant.filteredRooms.filter { $0.hasBreakfast || $0.allInclusive }
    }

    static func filterVariantRoomsByGates(_ rooms: [HDKRoom], gates: [String], hotelWebsiteString: String) -> [HDKRoom] {
        guard gates.count > 0 else { return rooms }

        return rooms.filter { (room) -> Bool in
            if gates.contains(room.gate.name ?? "") {
                return true
            }
            if gates.contains(hotelWebsiteString) && room.hasHotelWebsiteOption {
                return true
            }
            return false
        }
    }
}
