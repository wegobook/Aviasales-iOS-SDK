import UIKit

@objcMembers
class VariantsCounters: NSObject {
    let hotelsCountAccordingToOptions: [String: NSNumber]
    let hotelsCountAccordingToGates: [String: NSNumber]

    static let allAvailableAmenityKeys = ["0", "1", "3", "4", "5", "6", "7", "8", "9", "12", "13"]

    static let allAvailableOptionKeys = [RoomOptionConsts.kBreakfastOptionKey,
                                         RoomOptionConsts.kAllInclusiveOptionKey,
                                         RoomOptionConsts.kRefundableOptionKey,
                                         RoomOptionConsts.kSmokingOptionKey,
                                         RoomOptionConsts.kPayNowOptionKey,
                                         RoomOptionConsts.kPayLaterOptionKey,
                                         RoomOptionConsts.kNiceViewOptionKey,
                                         RoomOptionConsts.kRoomWifiOptionKey,
                                         RoomOptionConsts.kRoomDormitoryOptionKey]

    init(variants: [HLResultVariant]) {
        hotelsCountAccordingToOptions = VariantsCounters.countHotelsAccordingToOptions(variants: variants)
        hotelsCountAccordingToGates = FilterLogic.countHotelsAccordingToGates(variants, hotelWebsiteString:FilterLogic.hotelWebsiteAgencyName())
        super.init()
    }

    static private func countHotelsAccordingToAmenities(variants: [HLResultVariant]) -> [String: NSNumber] {
        var result: [String: NSNumber] = [:]
        for amenityKey in allAvailableAmenityKeys {
            for variant in variants {
                variant.dropRoomsFiltering()
            }
            let filtered = variants.filter { variant in
                variant.filterRooms(byAmenity: amenityKey)
                return variant.shouldIncludeToFilteredResults(byAmenity: amenityKey)
            }
            result[amenityKey] = NSNumber(value: filtered.count)
        }
        return result
    }

    static private func countHotelsAccordingToOptions(variants: [HLResultVariant]) -> [String: NSNumber] {
        var result: [String: NSNumber] = [:]
        for option in allAvailableOptionKeys {
            let filtered = variants.filter { $0.hasRooms(withOption: option) }
            result[option] = NSNumber(value: filtered.count)
        }
        return result
    }

}
