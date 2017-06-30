class ZoomKeepingPeekVC: MapPeekVC {

    var savedZoom: Double = 0
    var savedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let mapView = self.mapView, let variant = self.variant {
            if savedZoom > 0 {
                HLMapViewConfigurator.addAllAnnotations(mapView, variant: variant, filter: filter)
                mapView.setCenter(savedCoordinate, zoom: savedZoom, animated: false)
                savedZoom = 0
            }
        }
    }

    // MARK: - Public

    func setZoom(from mapView: HLMapView) {
        savedZoom = mapView.zoom()
        savedCoordinate = mapView.region.center
    }
}
