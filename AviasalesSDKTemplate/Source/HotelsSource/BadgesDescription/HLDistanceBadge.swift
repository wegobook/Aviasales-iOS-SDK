import UIKit

@objc enum DistancePointType: Int {
    case customLocation
    case userLocation
}

class HLDistanceBadge: HLPopularHotelBadge {
    let distance: Double
    let pointType: DistancePointType

    init(distance: Double, pointType: DistancePointType) {
        self.pointType = pointType
        self.distance = distance
        super.init()
        self.systemName = "distanceBadge"
    }
}
