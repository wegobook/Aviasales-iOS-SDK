class ImportantPointsMapVC: SingleHotelMapVC {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let mapView = mapView, let variant = variant {
            HLMapViewConfigurator.configure(mapView, toShowSelectedPoints: variant, filter: filter)
        }

    }
}
