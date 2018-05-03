@objcMembers
class PoiAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var poi: HDKLocationPoint?

    init(_ poi: HDKLocationPoint) {
        self.poi = poi
        self.coordinate = poi.location.coordinate
        self.title = StringUtils.locationPointName(poi)
    }
}
