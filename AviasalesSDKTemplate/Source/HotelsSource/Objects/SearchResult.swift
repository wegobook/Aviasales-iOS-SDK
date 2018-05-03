import Foundation

@objcMembers
@objc class SearchResult: NSObject {
    let variants: [HLResultVariant]
    let nearbyCities: [HDKCity]
    let searchInfo: HLSearchInfo
    var searchId: String?
    var counters: VariantsCounters = VariantsCounters(variants: [])

    lazy var allGatesNames: Set<String> = SearchResult.gatesNames(from: self.variants)
    lazy var allDistrictsNames: Set<String> = SearchResult.districtsNames(from: self.variants)

    init(searchInfo: HLSearchInfo, variants: [HLResultVariant] = [], nearbyCities: [HDKCity] = []) {
        self.searchInfo = searchInfo
        self.variants = variants
        self.nearbyCities = nearbyCities
        self.counters = VariantsCounters(variants: self.variants)
        super.init()
    }

    convenience init(searchInfo: HLSearchInfo) {
        self.init(searchInfo: searchInfo, variants: [], nearbyCities: [])
    }

    func hasAnyRoomWithPrice() -> Bool {
        return variants.index(where: { variant -> Bool in
            return variant.roomWithMinPrice != nil
        }) != nil
    }

    static func districtsNames(from variants: [HLResultVariant]) -> Set<String> {
        var districtsNames = Set<String>()

        for variant in variants {
            let hotel = variant.hotel

            if let firstDistrictName = hotel.firstDistrictName() {
                districtsNames.insert(firstDistrictName)
            }
        }

        return districtsNames
    }

    static func gatesNames(from variants: [HLResultVariant]) -> Set<String> {
        var gatesNames = Set<String>()

        for variant in variants {
            if let rooms = variant.roomsCopy() {
                for room in rooms {
                    if room.hasHotelWebsiteOption {
                        gatesNames.insert(FilterLogic.hotelWebsiteAgencyName())
                    } else {
                        gatesNames.insert(room.gate.name ?? "")
                    }
                }
            }
        }

        return gatesNames
    }
}
