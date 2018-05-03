import UIKit

@objc protocol HLCustomPointSelectionDelegate: NSObjectProtocol {
    func didSelectCustomSearchLocationPoint(_ searchLocationPoint: HDKSearchLocationPoint)
}

@objcMembers
class HLCustomPointSelectionVC: HLCommonVC, MKMapViewDelegate, HLLocateMeMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var pinBottomShadowImageView: UIImageView!
    @IBOutlet weak var pinBigShadowImageView: UIImageView!
    @IBOutlet weak var locateMeMapView: HLLocateMeMapView!

    weak var delegate: HLCustomPointSelectionDelegate?

    var initialSearchInfoLocation: CLLocation?
    let spanDegrees: CLLocationDegrees = iPad() ? 0.1 : 0.05

    // MARK: - VC lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLS("HL_LOC_SELECT_POINT_ON_MAP_TITLE")

        HLLocationManager.shared().hasUserGrantedLocationAccess(onCompletion: { accessGranted in
            self.mapView.showsUserLocation = accessGranted
        })

        locateMeMapView.delegate = self

        let sel = #selector(HLCustomPointSelectionVC.selectSearchLocationPoint)
        let doneItem = UIBarButtonItem(title:NSLS("HL_LOC_FILTER_APPLY_BUTTON"), style:.plain, target:self, action:sel)
        navigationItem.rightBarButtonItem = doneItem
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let searchInfoLocation = initialSearchInfoLocation {
            mapView.region = MKCoordinateRegionMake(searchInfoLocation.coordinate, MKCoordinateSpanMake(spanDegrees, spanDegrees))
            initialSearchInfoLocation = nil
        }
    }

    @objc func selectSearchLocationPoint() {
        let coordinate = mapView.convert(pinBottomShadowImageView.center, toCoordinateFrom: view)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        goBack()
        let point = HLCustomSearchLocationPoint(location: location, nearbyCities: [])
        delegate?.didSelectCustomSearchLocationPoint(point)
    }

    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKAnnotationView()
        pin.image = UIImage(named: "userLocationPin")

        return pin
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        locateMeMapView.locateMeButton.isSelected = false
    }

    // MARK: - HLLocateMeMapViewDelegate

    func locateMeMapView(_ locateMeMapView: HLLocateMeMapView, shouldShowUserLocation userLocation: CLLocation?) {
        guard let coordinate = userLocation?.coordinate else { return }

        var point = mapView.convert(coordinate, toPointTo: view)
        point.y -= bottomLayoutGuide.length / 2.0
        mapView.setCenter(mapView.convert(point, toCoordinateFrom: view), animated: true)
        locateMeMapView.locateMeButton.isSelected = true

        HLLocationManager.shared().hasUserGrantedLocationAccess(onCompletion: { accessGranted in
            self.mapView.showsUserLocation = accessGranted
        })
    }

}
