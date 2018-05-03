import Foundation

typealias ComparisonFunc = (HLResultVariant, HLResultVariant) -> ComparisonResult

@objcMembers
class VariantsSorter: NSObject {

    class func sortVariants(_ variants: [HLResultVariant], withType type: SortType, searchInfo: HLSearchInfo) -> [HLResultVariant] {
        switch type {
        case .price:
            return sortVariantsByPrice(variants)
        case .distance:
            return sortVariantsByDistance(variants)
        case .rating:
            return sortVariantsByRating(variants)
        case .popularity:
            return sortVariantsByPopularity(variants, searchInfo: searchInfo)
        case .discount:
            return sortVariantsByDiscount(variants)
        case .bookingsCount:
            return sortVariantsByBookingsCount(variants)
        }
    }

    internal class func sortVariants(_ variants: [HLResultVariant], withComparisonFunc comparisonFunc: @escaping ComparisonFunc) -> [HLResultVariant] {
        let variantsNSArray: NSArray = variants as NSArray

        let comparator: Comparator = {(obj1, obj2) -> ComparisonResult in
            if let variant1 = obj1 as? HLResultVariant, let variant2 = obj2 as? HLResultVariant {
                return comparisonFunc(variant1, variant2)
            }

            return .orderedSame
        }

        return variantsNSArray.sortedArray(options: [.stable, .concurrent], usingComparator: comparator) as! [HLResultVariant]
    }

    class func sortVariantsByDiscount(_ variants: [HLResultVariant]) -> [HLResultVariant] {
        return sortVariants(variants, withComparisonFunc: addCheckRoomsCondition(getDiscountComparator()))
    }

    class func sortVariantsByPopularity(_ variants: [HLResultVariant], searchInfo: HLSearchInfo) -> [HLResultVariant] {
        let sortFunc = getPopularityComparator()

        return sortVariants(variants, withComparisonFunc: sortFunc)
    }

    class func sortVariantsByRating(_ variants: [HLResultVariant]) -> [HLResultVariant] {
        return sortVariants(variants, withComparisonFunc: addCheckRoomsCondition(addRatingCondition(getPriceComparator())))
    }

    class func sortVariantsByPrice(_ variants: [HLResultVariant]) -> [HLResultVariant] {
        return sortVariants(variants, withComparisonFunc: addCheckRoomsCondition(getPriceComparator()))
    }

    class func sortVariantsByDistance(_ variants: [HLResultVariant]) -> [HLResultVariant] {
        return sortVariants(variants, withComparisonFunc: addCheckRoomsCondition(getDistanceComparator()))
    }

    class func sortVariantsByBookingsCount(_ variants: [HLResultVariant]) -> [HLResultVariant] {
        return sortVariants(variants, withComparisonFunc: addCheckRoomsCondition(getBookingsCountComparator()))
    }

    class func localizedNameForSortType(_ sortType: SortType) -> String {
        switch sortType {
        case .popularity:
            return NSLS("HL_LOC_SORT_TYPE_POPULARITY")
        case .price:
            return NSLS("HL_LOC_SORT_TYPE_PRICE")
        case .rating:
            return NSLS("HL_LOC_SORT_TYPE_RATING")
        case .distance:
            return NSLS("HL_LOC_SORT_TYPE_DISTANCE")
        case .discount:
            return NSLS("HL_LOC_SORT_TYPE_DISCOUNT")
        case .bookingsCount:
            return "Bookings count"
        }
    }

    // MARK: Private

    internal class func getPopularityComparator() -> ComparisonFunc {
        return { $0.hotel.popularity.compare($1.hotel.popularity) }
    }

    fileprivate class func getDiscountComparator() -> ComparisonFunc {
        return { (variant1: HLResultVariant, variant2: HLResultVariant) -> ComparisonResult in

            let discount1 = variant1.highlightType == .discount ? normalizeDiscountValue(variant1.discount) : 0
            let discount2 = variant2.highlightType == .discount ? normalizeDiscountValue(variant2.discount) : 0

            let discountComparisonResult = discount1.compare(discount2)
            if discountComparisonResult != .orderedSame {
                return discountComparisonResult
            }

            let offer1 = variant1.highlightType == .mobile || variant1.highlightType == .private
            let offer2 = variant2.highlightType == .mobile || variant2.highlightType == .private

            if offer1 && offer2 {
                return variant1.minPrice.compare(variant2.minPrice)
            }

            if offer1 {
                return .orderedAscending
            }
            if offer2 {
                return .orderedDescending
            }

            return variant1.hotel.popularity.compare(variant2.hotel.popularity)
        }
    }

    fileprivate class func normalizeDiscountValue(_ rawDiscount: Int) -> Int {
        if rawDiscount < HDKRoom.kDiscountHighCutoff || rawDiscount > HDKRoom.kDiscountLowCutoff {
            return 0
        }
        return -rawDiscount
    }

    fileprivate class func getPriceComparator() -> ComparisonFunc {
        return { $1.minPrice.compare($0.minPrice) }
    }

    fileprivate class func getRatingComparator() -> ComparisonFunc {
        return { $0.hotel.rating.compare($1.hotel.rating) }
    }

    fileprivate class func getDistanceComparator() -> ComparisonFunc {
        return { $1.distanceToCurrentLocationPoint.compare($0.distanceToCurrentLocationPoint)}
    }

    fileprivate class func getBookingsCountComparator() -> ComparisonFunc {
        return { $0.hotel.popularity2.compare($1.hotel.popularity2)}
    }

    fileprivate class func addRatingCondition(_ origFunc: @escaping ComparisonFunc) -> ComparisonFunc {

        let ratingComparator = getRatingComparator()
        let decorator: ComparisonFunc = { (variant1, variant2) in

            let comparisonResult = ratingComparator(variant1, variant2)
            if comparisonResult != .orderedSame {
                return comparisonResult
            }

            return origFunc(variant1, variant2)
        }

        return decorator
    }

    internal class func addCheckRoomsCondition(_ origFunc: @escaping ComparisonFunc) -> ComparisonFunc {

        let decorator: ComparisonFunc = { (variant1, variant2) in

            let roomsAvailability1 = variant1.roomsAvailability()
            let roomsAvailability2 = variant2.roomsAvailability()

            if roomsAvailability1 == .hasRooms && roomsAvailability2 != .hasRooms {
                return .orderedAscending
            }
            if roomsAvailability1 == .sold && roomsAvailability2 == .noRooms {
                return .orderedAscending
            }
            if roomsAvailability2 == .hasRooms && roomsAvailability1 != .hasRooms {
                return .orderedDescending
            }
            if roomsAvailability2 == .sold && roomsAvailability1 == .noRooms {
                return .orderedDescending
            }

            return origFunc(variant1, variant2)
        }

        return decorator
    }
}
