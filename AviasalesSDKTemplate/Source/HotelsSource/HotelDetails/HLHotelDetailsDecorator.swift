@objc protocol HLHotelDetailsDecoratorProtocol: NSObjectProtocol {

    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func goBack()

    @objc optional func hotelInfoWillLoad()
    @objc optional func hotelInfoDidLoad(withError error: NSError?)
}

@objcMembers
class HLHotelDetailsDecorator: NSObject, HLHotelDetailsDecoratorProtocol {

    fileprivate(set) var detailsVC: HLHotelDetailsVC!

    convenience init(variant: HLResultVariant!, photoIndex: Int = 0, photoIndexUpdater: PhotoIndexUpdaterBlock? = nil, filter: Filter? = nil) {
        self.init()

        self.detailsVC.variant = variant
        self.detailsVC.photoIndex = photoIndex
        self.detailsVC.visiblePhotoIndexUpdater = photoIndexUpdater
        self.detailsVC.decoratorDelegate = self
        self.detailsVC.filter = filter
    }

    override init() {
        super.init()

        if iPad() {
            detailsVC = HLIpadHotelDetailsVC(nibName: "HLIpadHotelDetailsVC", bundle: nil)
        } else {
            detailsVC = HLIphoneHotelDetailsVC(nibName: "HLIphoneHotelDetailsVC", bundle: nil)
        }
    }

    // MARK: - HLHotelDetailsDecoratorProtocol methods

    func viewDidLoad() {
    }

    func viewWillAppear() {
    }

    func viewDidAppear() {
    }

    func goBack() {
        _ = detailsVC.navigationController?.popViewController(animated: true)
    }

}
