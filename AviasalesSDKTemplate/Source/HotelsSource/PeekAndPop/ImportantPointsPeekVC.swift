class ImportantPointsPeekVC: MapPeekVC {

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let mapView = mapView, let variant = variant {
            HLMapViewConfigurator.configure(mapView, toShowSelectedPoints: variant, filter: filter)
        }
    }
}
