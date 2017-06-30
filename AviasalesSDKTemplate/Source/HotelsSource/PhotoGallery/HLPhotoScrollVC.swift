import UIKit

@objc protocol HLPhotoScrollVCDelegate: class {
    func photoScrollDidClose(_ photoScrollVC: HLPhotoScrollVC)
}

class HLPhotoScrollVC: HLCommonPhotoVC {

    fileprivate var startGestureVelocity: CGPoint!
    fileprivate var statusBarHidden: Bool = false

    fileprivate var zoomablePhotoScrollView: HLZoomablePhotoScrollView {
        return self.photoScrollView as! HLZoomablePhotoScrollView
    }

    weak var delegate: HLPhotoScrollVCDelegate?

    // MARK: - Override methods

    convenience init() {
        self.init(nibName: "HLPhotoScrollVC", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        photoScrollView.placeholderImage = UIImage.photoPlaceholder
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }

    // MARK: - HLCommonPhotoVC override methods

    override var imageSize: CGSize {
        return HLPhotoManager.defaultHotelPhotoSize
    }

    override func updateCounterLabel() {
        let totalCount = self.photoScrollView.content.count

        if totalCount <= 1 {
            self.counterLabel.isHidden = true
            self.counterIcon!.isHidden = true
        } else {
            self.counterLabel.text = StringUtils.photoCounterString(self.currentPhotoIndex, totalCount: totalCount)
            self.counterLabel.isHidden = false
            self.counterIcon!.isHidden = false
        }
    }

    // MARK: - IBAction methods

    @IBAction fileprivate func close(_ sender: AnyObject) {
        delegate?.photoScrollDidClose(self)
    }
}

extension HLPhotoScrollVC {

    func photoScrollPhotoIndexChanged(_ index: Int) {
        currentPhotoIndex = index
        updateCounterLabel()
    }

}
