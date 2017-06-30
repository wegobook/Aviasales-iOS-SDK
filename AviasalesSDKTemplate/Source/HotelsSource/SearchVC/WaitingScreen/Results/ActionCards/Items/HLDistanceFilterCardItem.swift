import UIKit

class HLDistanceFilterCardItem: HLActionCardItem {

    var originPoint: HDKLocationPoint
    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 1.0
    var currentValue: CGFloat = 0.0 {
        didSet {
            if oldValue != 0.0 && oldValue != currentValue {
                didChangeSliderValue = true
            }
        }
    }
    var didChangeSliderValue = false

    private let bigDistanceMeters: CGFloat = 5000.0
    private let minHotelsCount = 10

    init(topItem: Bool, cellReuseIdentifier: String, filter: Filter, delegate: HLActionCellDelegate, searchInfo: HLSearchInfo) {
        originPoint = HLDistanceFilterCardItem.selectOriginPoint(searchInfo)
        super.init(topItem: topItem, cellReuseIdentifier: cellReuseIdentifier, filter: filter, delegate: delegate)
        calculateSliderBounds()
    }

    func update(_ filter: Filter) {
        if originPoint == (filter.distanceLocationPoint ?? nil) {
            if didChangeSliderValue || filter.currentMaxDistance != filter.maxDistance {
                currentValue = filter.currentMaxDistance
            }
        }
    }

    private func calculateSliderBounds() {
        if originPoint != filter!.distanceLocationPoint {
            minValue = CGFloat.greatestFiniteMagnitude
            maxValue = -1

            if let variants = filter!.searchResult?.variants {
                for variant in variants {
                    var distance = CGFloat.greatestFiniteMagnitude
                    if originPoint is HLGenericCategoryLocationPoint {
                        distance = HLDistanceCalculator.getDistanceFrom(variant.hotel, toPointsOfCategory: originPoint.category, undefinedDistance: distance)
                    } else {
                        distance = CGFloat(HLDistanceCalculator.getDistanceFrom(originPoint, to: variant.hotel))
                    }
                    if distance != CGFloat.greatestFiniteMagnitude {
                        variant.distanceToCurrentLocationPoint = distance
                        maxValue = max(maxValue, distance)
                        minValue = min(distance, minValue)
                    }
                }
                minValue += 0.01
                maxValue += 0.01
            }
        } else {
            minValue = filter!.minDistance
            maxValue = filter!.maxDistance
        }
        currentValue = presetFilterValue(originPoint, filter: filter!, shouldUseMetricSystem: true)//HLLocaleInspector.shouldUseMetricSystem())
        if currentValue < minValue || currentValue > maxValue {
            currentValue = maxValue
        } else if shouldAutoApplyFilter(to: originPoint) {
            filter!.distanceLocationPoint = originPoint
            filter!.currentMaxDistance = currentValue
            delegate?.filterUpdated(filter)
            didChangeSliderValue = true
        }
    }

    func presetFilterValue(_ point: HDKLocationPoint, filter: Filter, shouldUseMetricSystem: Bool) -> CGFloat {
        let minDistance = minPresetFilterValue(point, shouldUseMetricSystem: shouldUseMetricSystem)
        let distanceToRemainHotels = distanceToRemainMinHotelsCount(variants: filter.allVariants) ?? 0

        return max(minDistance, distanceToRemainHotels)
    }

    private func distanceToRemainMinHotelsCount(variants: [HLResultVariant]) -> CGFloat? {
        let sortedByDistance = VariantsSorter.sortVariantsByDistance(variants)
        return sortedByDistance.prefix(minHotelsCount).last?.distanceToCurrentLocationPoint
    }

    private func minPresetFilterValue(_ point: HDKLocationPoint, shouldUseMetricSystem: Bool) -> CGFloat {
        if shouldAutoApplyFilter(to: point) {
            return bigDistanceMeters
        } else {
            return maxValue
        }
    }

    private func shouldAutoApplyFilter(to point: HDKLocationPoint) -> Bool {
        return point is HLCustomLocationPoint || point is HLAirportLocationPoint
    }

    class func selectOriginPoint(_ searchInfo: HLSearchInfo) -> HDKLocationPoint {

        if let locationPoint = searchInfo.locationPoint as? HLSearchUserLocationPoint {
            return HLCustomLocationPoint(name: NSLS("HL_LOC_SEARCH_POINT_TEXT"), location: locationPoint.location)
        }
        if let locationPoint = searchInfo.locationPoint as? HLCustomSearchLocationPoint {
            return HLCustomLocationPoint(name: NSLS("HL_LOC_SEARCH_POINT_TEXT"), location: locationPoint.location)
        }
        if let locationPoint = searchInfo.locationPoint as? HLSearchCityCenterLocationPoint {
            var pointName = NSLS("HL_LOC_FILTERS_POINT_CITY_CENTER_TEXT")
            let city = locationPoint.city!
            if let cityName = city.name {
                pointName = pointName + " (" + cityName + ")"
            }
            return HLCityAndNearbyPoint(name: pointName, location: locationPoint.location, city: city)
        }
        if let locationPoint = searchInfo.locationPoint as? HLSearchAirportLocationPoint {
            return HLAirportLocationPoint(name: locationPoint.title, location: locationPoint.location)
        }
        if let city = searchInfo.city ?? searchInfo.locationPoint?.city,
            let checkIn = searchInfo.checkInDate,
            let checkOut = searchInfo.checkOutDate {
                let seasonCategory = city.seasonCategory(at: checkIn, and: checkOut)
                switch seasonCategory {
                case HDKSeason.kBeachSeasonCategory:
                    return HLGenericCategoryLocationPoint(category: HDKLocationPointCategory.kBeach)
                case HDKSeason.kSkiSeasonCategory:
                    return HLGenericCategoryLocationPoint(category: HDKLocationPointCategory.kSkilift)
                default:
                    return HLCityLocationPoint(city: city)
                }
        }

        assertionFailure()
        return HDKLocationPoint(name: "", location: CLLocation(latitude: 0, longitude: 0))
    }

}
