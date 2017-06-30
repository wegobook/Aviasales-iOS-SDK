import MapKit

class PeekHotelMapCell: PeekTableCell, MKMapViewDelegate {

    @IBOutlet weak private var overlayView: UIView!
    @IBOutlet weak private var mapView: HLMapView!

    override func configure(_ item: PeekItem) {
        super.configure(item)

        guard let mapItem = item as? MapPeekItem else { return }
        HLMapViewConfigurator.configure(mapView, toShowVariantAndSearchPoint: mapItem.variant, filter: mapItem.filter)
    }

    // MARK: - Override methods

    override func awakeFromNib() {
        super.awakeFromNib()

        mapView.backgroundColor = UIColor.clear
        mapView.isUserInteractionEnabled = false
        mapView.delegate = self
    }

    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return HLMapViewConfigurator.viewForAnnotation(annotation, mapView: mapView, city: item?.variant.hotel.city)
    }

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        hideOverlayView()
    }

    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        hideOverlayView()
    }

    // MARK: - Private

    private func hideOverlayView() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.overlayView.alpha = 0.0
        }
    }
}
