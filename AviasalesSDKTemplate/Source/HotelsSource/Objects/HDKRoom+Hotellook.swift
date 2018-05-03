import Foundation
import HotellookSDK

@objcMembers
class RoomOptionConsts: NSObject {
    static let kBreakfastOptionKey = "breakfast"
    static let kAllInclusiveOptionKey = "allInclusive"
    static let kRefundableOptionKey = "refundable"
    static let kAvailableRoomsOptionKey = "available"
    static let kSmokingOptionKey = "smoking"
    static let kPayNowOptionKey = "deposit"
    static let kPayLaterOptionKey = "!deposit"
    static let kPrivatePriceOptionKey = "privatePrice"
    static let kCardRequiredOptionKey = "cardRequired"
    static let kViewSentenceOptionKey = "viewSentence"
    static let kNiceViewOptionKey = "view"
    static let kFanOptionKey = "fan"
    static let kRoomAirConditioningOptionKey = "airConditioner"
    static let kRoomWifiOptionKey = "freeWifi"
    static let kRoomDormitoryOptionKey = "dormitory"
    static let kRoomPrivateBathroomKey = "privateBathroom"

    static let kHotelSharedBathroomKey = "shared bathroom"
    static let kHotelAirConditioningOptionKey = "air conditioning"
    static let kHotelWifiInRoomOptionKey = "wi-fi in room"
}

@objc extension HDKRoom {

    static let kDiscountLowCutoff = -3
    static let kDiscountHighCutoff = -75

    func hasDiscountHighlight() -> Bool {
        return highlightType() == .discount
    }

    private func discountInAllowedRange() -> Bool {
        return (discount <= HDKRoom.kDiscountLowCutoff) && (discount >= HDKRoom.kDiscountHighCutoff)
    }

    func hasPrivatePriceHighlight() -> Bool {
        let highlight = highlightType()
        return highlight == .mobile || highlight == .private
    }

    func highlightType() -> HDKHighlightType {
        let result = HDKRoom.highlightType(by: highlightTypeString)

        if result == .discount && !discountInAllowedRange() {
            assertionFailure()
            return .none
        }

        if (result == .mobile || result == .private) && !hasMobileOrPrivatePriceOption {
            assertionFailure()
            return .none
        }

        return result
    }

    func hasOption(_ option: String, withValue expectedValue: Bool) -> Bool {
        if option == RoomOptionConsts.kBreakfastOptionKey {
            return options.breakfast == expectedValue
        }
        if option == RoomOptionConsts.kRefundableOptionKey {
            return options.refundable == expectedValue
        }
        if option == RoomOptionConsts.kPayNowOptionKey {
            return options.deposit == expectedValue
        }
        if option == RoomOptionConsts.kAllInclusiveOptionKey {
            return options.allInclusive == expectedValue
        }
        if option == RoomOptionConsts.kRoomWifiOptionKey {
            return options.freeWifi == expectedValue
        }
        if option == RoomOptionConsts.kNiceViewOptionKey {
            return (options.view != nil) && expectedValue
        }
        if option == RoomOptionConsts.kSmokingOptionKey {
            return options.smoking == expectedValue
        }
        if option == RoomOptionConsts.kRoomDormitoryOptionKey {
            return options.dormitory == expectedValue
        }

        assertionFailure()
        return false
    }

    private static func highlightType(by highlightString: String?) -> HDKHighlightType {
        let map: [String: HDKHighlightType] = [
            "mobile": .mobile,
            "private": .private,
            "discount": .discount
        ]

        guard let highlightString = highlightString else {
            return .none
        }
        return map[highlightString] ?? .none
    }

}
