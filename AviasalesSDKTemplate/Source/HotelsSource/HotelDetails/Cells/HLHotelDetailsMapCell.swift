private let kMapOnlyCellHeight: CGFloat = 250.0
private let kLabelMarginsLength: CGFloat = 30.0

class HLHotelDetailsMapCell: HLHotelDetailsTableCell, MKMapViewDelegate {

    var variant: HLResultVariant?
    var filter: Filter?

    @IBOutlet weak fileprivate var overlayView: UIView!
    @IBOutlet weak fileprivate var addressBackground: UIView!
    @IBOutlet weak var mapView: HLMapView!
    @IBOutlet weak fileprivate var addressLabel: UILabel!
    @IBOutlet var addressDetailsZeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var betweenAddressConstraint: NSLayoutConstraint!

    class func estimatedHeight(_ hotel: HDKHotel?, width: CGFloat) -> CGFloat {
        var cellHeight = kMapOnlyCellHeight

        let hotelAddress = StringUtils.hotelAddress(for: hotel)
        let hotelAddressIsEmpty = hotelAddress.count == 0

        if !hotelAddressIsEmpty {
            let font = UIFont.systemFont(ofSize: 13.0)
            let textHeight = hotelAddress.hl_height(attributes: [NSAttributedStringKey.font: font], width: width - kLabelMarginsLength)
            cellHeight += textHeight
        }

        return cellHeight
    }

    func setMapRegion() {
        guard let variant = variant else { return }

        let address = StringUtils.hotelAddress(for: variant.hotel)
        addressLabel.text = address
        addressBackground.isHidden = address.count == 0
        HLMapViewConfigurator.configure(mapView, toShowVariantAndSearchPoint: variant, filter: filter)
    }

    // MARK: - Override methods

    override func awakeFromNib() {
        super.awakeFromNib()

        mapView.backgroundColor = UIColor.clear
        mapView.isUserInteractionEnabled = false
        mapView.delegate = self
        mapView.layer.cornerRadius = 6.0

        let copyAddressLongPressGestureRecognizer = UILongPressGestureRecognizer()
        addressBackground.addGestureRecognizer(copyAddressLongPressGestureRecognizer)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // do nothing
    }

    // MARK: - MKMapViewDelegate

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.overlayView.alpha = 0.0
        })
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return HLMapViewConfigurator.viewForAnnotation(annotation, mapView: mapView, city: variant?.hotel.city)
    }
}
