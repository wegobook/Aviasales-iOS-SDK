import UIKit

@objc protocol HLLocateMeMapViewDelegate: NSObjectProtocol {
    func locateMeMapView(_ locateMeMapView: HLLocateMeMapView, shouldShowUserLocation userLocation: CLLocation?)
}

@objcMembers
@IBDesignable class HLLocateMeMapView: UIView, HLLocationManagerDelegate {

    var shouldNotifyDelegateOnLocationUpdate = false
    var shouldDetectLocation = true

    @IBOutlet weak var delegate: HLLocateMeMapViewDelegate?
    @IBOutlet weak var locateMeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locateMeButton: UIButton!
    @IBOutlet weak var blurContainer: UIView!

    // MARK: - VC Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        initialize()
    }

    deinit {
        unregisterNotificationResponse()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    func notifyDelegateWithLocation(_ location: CLLocation?) {
        delegate?.locateMeMapView(self, shouldShowUserLocation: location)
    }

    // MARK: - HLLocationManagerDelegate

    func locationUpdatedNotification(_ notification: Notification!) {
        endLoadingRoutine()

        if shouldNotifyDelegateOnLocationUpdate {
            notifyDelegateWithLocation(notification.object as? CLLocation)
            shouldNotifyDelegateOnLocationUpdate = false
        }
    }

    func locationUpdateFailedNotification(_ notification: Notification!) {
        endLoadingRoutine()
    }

    func locationServicesAccessFailedNotification(_ notification: Notification!) {
        endLoadingRoutine()
    }

    // MARK: - IBActions

    @IBAction func locateMeAction() {
        if !shouldDetectLocation {
            notifyDelegateWithLocation(nil)
        } else if let location = HLLocationManager.shared().location() {
            notifyDelegateWithLocation(location)
        } else {
            startLoadingRoutine()
            HLLocationManager.shared().requestUserLocation(withLocationDestination: kShowCurrentLocationOnMap)
            shouldNotifyDelegateOnLocationUpdate = true
        }
    }

    // MARK: - Private

    private func initialize() {
        let view = loadViewFromNib("HLLocateMeMapView", self)!
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        blurContainer.layer.borderWidth = UIView.onePixel
        blurContainer.layer.borderColor = UIColor(hex: 0xCED0D0).cgColor
        addSubview(view)
        view.autoPinEdgesToSuperviewEdges()

        if shouldDetectLocation {
            registerForLocationManagerNotifications()
        }
    }

    func startLoadingRoutine() {
        locateMeButton.isHidden = true
        locateMeActivityIndicator.startAnimating()
    }

    func endLoadingRoutine() {
        locateMeButton.isHidden = false
        locateMeActivityIndicator.stopAnimating()
    }
}
