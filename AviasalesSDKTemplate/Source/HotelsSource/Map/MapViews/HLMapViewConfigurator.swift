class HLMapViewConfigurator: NSObject {

    static let kMapRegionMultiplier: Double = 1.2

    // MARK: - Public

    static func viewForAnnotation(_ annotation: MKAnnotation, mapView: MKMapView, city: HDKCity?) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let pin = MKAnnotationView()
            pin.image = UIImage(named: "userLocationPin")
            return pin
        } else if let poiAnnotation = annotation as? PoiAnnotation {
            let pin = HLPoiIconSelector.annotationView(poiAnnotation, mapView: mapView, city: city)
            pin?.layer.zPosition = CGFloat(HL_POI_ANNOTATION_ZPOSITION)
            return pin
        } else {
            let pin = MKAnnotationView()
            pin.image = UIImage(named: "redHotelPin")
            pin.layer.zPosition = CGFloat(HL_HOTEL_ANNOTATION_ZPOSITION)
            pin.centerOffset = CGPoint(x: 0, y: -11)
            return pin
        }
    }

    static func isAnnotation(_ annotation: PoiAnnotation, toCloseToEdgeIn mapView: MKMapView) -> Bool {
        let screenPoint = mapView.convert(annotation.coordinate, toPointTo: mapView)
        let offset: CGFloat = 10.0
        return screenPoint.x < offset ||
            screenPoint.x > mapView.frame.width - offset ||
            screenPoint.y < offset ||
            screenPoint.y > mapView.frame.height - offset
    }

    static func configure(_ mapView: HLMapView, toShowVariantAndSearchPoint variant: HLResultVariant, filter: Filter?) {
        if let filterSelectedPoint = HLPoiManager.filterPoint(filter, variant: variant) {
            configure(mapView, variant: variant, visiblePoi: [filterSelectedPoint], poiToCalculateRegion: [filterSelectedPoint])
        } else if let city = variant.hotel.city, city.isValid() {
            let cityCenter = HLCityLocationPoint(city: city)
            configure(mapView, variant: variant, visiblePoi: [cityCenter], poiToCalculateRegion: [cityCenter])
        } else {
            configure(mapView, variant: variant)
        }
    }

    static func configure(_ mapView: HLMapView, toShowSelectedPoints variant: HLResultVariant, filter: Filter?) {
        let poiToCalculate = HLPoiManager.selectHotelDetailsPoints(variant, filter: filter)
        let visiblePoi = HLPoiManager.allPoints(variant.hotel, filter: filter)
        configure(mapView, variant: variant, visiblePoi: visiblePoi, poiToCalculateRegion: poiToCalculate)
    }

    static func configure(_ mapView: HLMapView, variant: HLResultVariant) {
        mapView.setCenter(CLLocationCoordinate2D(latitude: CLLocationDegrees(variant.hotel.latitude), longitude: CLLocationDegrees(variant.hotel.longitude)), zoom: 15.0, animated: false)
        addHotelAnnotation(mapView, hotel: variant.hotel)
    }

    static func addAllAnnotations(_ mapView: HLMapView, variant: HLResultVariant, filter: Filter?) {
        let poiArray = HLPoiManager.allPoints(variant.hotel, filter: filter)
        addAnnotations(mapView, withVariant: variant, andPoiArray: poiArray)
    }

    // MARK: - Private

    private static func configure(_ mapView: HLMapView, variant: HLResultVariant, visiblePoi: [HDKLocationPoint], poiToCalculateRegion: [HDKLocationPoint]) {
        addAnnotations(mapView, withVariant: variant, andPoiArray: visiblePoi)
        let region = regionContaining(variant.hotel, poiArray: poiToCalculateRegion)
        mapView.setRegion(region, insets: HLMapView.defaultInsets(), animated: false)
    }

    private static func addAnnotations(_ mapView: HLMapView, withVariant variant: HLResultVariant, andPoiArray poiArray: [HDKLocationPoint]) {
        mapView.removeAnnotations(mapView.annotations)

        addHotelAnnotation(mapView, hotel: variant.hotel)
        addPoiAnnotations(mapView, poiArray: poiArray)
    }

    private static func addHotelAnnotation(_ mapView: HLMapView, hotel: HDKHotel) {
        let hotelCoordinates = CLLocationCoordinate2DMake(Double(hotel.latitude), Double(hotel.longitude))
        let hotelAnnotation = HotelAnnotation(coordinate: hotelCoordinates)
        mapView.addAnnotation(hotelAnnotation)
    }

    private static func addPoiAnnotations(_ mapView: HLMapView, poiArray: [HDKLocationPoint]) {
        let poiAnnotations = poiArray.map { PoiAnnotation($0) }
        mapView.addAnnotations(poiAnnotations)
    }

    // MARK: - Distance calculations

    fileprivate static func regionContaining(_ hotel: HDKHotel, poiArray: [HDKLocationPoint]) -> MKCoordinateRegion {
        var minLat = CLLocationDegrees(hotel.latitude)
        var maxLat = CLLocationDegrees(hotel.latitude)
        var minLon = CLLocationDegrees(hotel.longitude)
        var maxLon = CLLocationDegrees(hotel.longitude)

        for point in poiArray {
            minLat = min(minLat, point.location.coordinate.latitude)
            maxLat = max(maxLat, point.location.coordinate.latitude)
            minLon = min(minLon, point.location.coordinate.longitude)
            maxLon = max(maxLon, point.location.coordinate.longitude)
        }
        let center = CLLocationCoordinate2DMake((maxLat + minLat) / 2.0, (maxLon + minLon) / 2.0)
        let span = MKCoordinateSpanMake((maxLat - minLat) * kMapRegionMultiplier, (maxLon - minLon) * kMapRegionMultiplier)

        return MKCoordinateRegionMake(center, span)
    }

    fileprivate static func singleHotelRegion(_ hotel: HDKHotel) -> MKCoordinateRegion {
        let location = CLLocationCoordinate2DMake(CLLocationDegrees(hotel.latitude), CLLocationDegrees(hotel.longitude))
        return MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.01, 0.01))
    }
}
