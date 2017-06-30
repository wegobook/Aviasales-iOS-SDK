import UIKit

class HLCommonPhotoVC: HLCommonVC {

    @IBOutlet fileprivate(set) weak var closeButton: UIButton!
    @IBOutlet fileprivate(set) weak var counterLabel: UILabel!
    @IBOutlet fileprivate(set) weak var counterIcon: UIImageView?
    @IBOutlet fileprivate(set) weak var photoScrollView: HLPhotoCollectionView!

    fileprivate var canRotate = iPad()
    fileprivate var needRelayoutPhotoScrollView: Bool = true

    var currentPhotoIndex: Int = 0

    var imageSize: CGSize {
        return CGSize.zero
    }

    var hotel: HDKHotel! {
        didSet {
            self.setupContent()
        }
    }

    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        photoScrollView.backgroundColor = UIColor.clear
        photoScrollView.delegate = self
        title = NSLS("HL_HOTEL_DETAIL_SEGMENTED_PHOTOS_SECTION")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupContent()
        self.updateCounterLabel()

        self.needRelayoutPhotoScrollView = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if self.needRelayoutPhotoScrollView {
            self.photoScrollView.relayoutContent()

            self.needRelayoutPhotoScrollView = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.canRotate = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        canRotate = iPad()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.needRelayoutPhotoScrollView = true
    }

    // MARK: - Rotation methods

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.canRotate ? UIInterfaceOrientationMask.all : UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.canRotate ? super.preferredInterfaceOrientationForPresentation : .portrait
    }

    // MARK: - Internal methods

    func setupContent() {
        guard self.isViewLoaded else { return }

        self.photoScrollView.updateDataSource(withHotel: self.hotel, imageSize: self.imageSize, useThumbs: (self is HLPhotoScrollVC))
        self.photoScrollView.scrollToPhotoIndex(self.currentPhotoIndex, animated: false)

        self.updateCounterLabel()
    }

    func updateCounterLabel() {
    }

}

extension HLCommonPhotoVC: HLPhotoScrollViewDelegate {

    func photoScrollBeginZooming() {
        self.photoScrollView.collectionView.isScrollEnabled = false
    }

    func photoScrollEndZooming() {
        self.photoScrollView.collectionView.isScrollEnabled = true
    }

}
