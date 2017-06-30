import MapKit

class SingleHotelMapVC: HLCommonVC, MKMapViewDelegate {

    @IBOutlet weak var mapView: HLMapView?
    var variant: HLResultVariant?
    var filter: Filter?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = variant?.hotel.name
    }

    deinit {
        mapView?.delegate = nil
    }

    @IBAction func showRoute(_ sender: UIView) {
        showRouteInAppleMaps()
    }

    private func showRouteInAppleMaps() {
        guard let hotel = variant?.hotel else { return }

        RouteHelper.showRouteInAppleMaps(toLatitude: CGFloat(hotel.latitude), toLongitude: CGFloat(hotel.longitude))
    }

    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return HLMapViewConfigurator.viewForAnnotation(annotation, mapView: mapView, city: variant?.hotel.city)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.layer.zPosition = CGFloat(HL_SELECTED_ANNOTATION_ZPOSITION)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.layer.zPosition = CGFloat(HL_POI_ANNOTATION_ZPOSITION)
    }

}
