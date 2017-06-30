import UIKit

class HLDistanceBadgeView: HLBadgeView {
    @IBOutlet var label: UILabel!
    @IBOutlet var iconView: UIImageView!

    static func badgeView() -> HLDistanceBadgeView {
        return loadViewFromNibNamed("HLDistanceBadgeView") as! HLDistanceBadgeView
    }

    func configure(for distance: Double, pointType: DistancePointType) {
        label.text = StringUtils.roundedDistance(withMeters: CGFloat(distance))
        iconView.image = image(for: pointType)
    }

    func image(for pointType: DistancePointType) -> UIImage {
        switch pointType {
        case .userLocation:
            return #imageLiteral(resourceName: "locationDistanceBadgeIcon")
        case .customLocation:
            return #imageLiteral(resourceName: "pointDistanceBadgeIcon")
        }
    }
}
