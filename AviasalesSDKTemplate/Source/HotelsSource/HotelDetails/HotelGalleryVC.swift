import UIKit

class HotelGalleryVC: HotelDetailsMoreVC, HLPhotoCollectionViewDelegate, HLPhotoGridViewDelegate, HLPhotoScrollVCDelegate, UIViewControllerPreviewingDelegate {
    @IBOutlet weak var photoGridView: HLPhotoGridView!

    init(variant: HLResultVariant) {
        super.init(variant: variant, nibName: "HotelGalleryVC")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLS("HL_HOTEL_DETAIL_SEGMENTED_PHOTOS_SECTION")
        photoGridView.collectionView.backgroundColor = JRColorScheme.mainBackgroundColor()
        photoGridView.delegate = self

        let thumbSize = HLPhotoManager.calculateThumbSizeForColumnsCount(3, containerWidth: view.bounds.width)
        photoGridView.updateDataSource(withHotel: variant.hotel, imageSize: thumbSize, thumbSize: thumbSize, useThumbs: true)

        if #available(iOS 9.0, *) {
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    func photoCollectionViewDidSelectPhotoAtIndex(_ index: Int) {
        let vc = HLPhotoScrollVC()
        vc.hotel = variant.hotel
        vc.currentPhotoIndex = index
        vc.delegate = self
        vc.view.backgroundColor = UIColor.black

        navigationController?.pushViewController(vc, animated: true)

    }

    func photoScrollDidClose(_ photoScrollVC: HLPhotoScrollVC) {
        photoScrollVC.dismiss(animated: true, completion: nil)
    }

    // MARK: - HLPhotoGridViewDelegate
    func columnInset() -> CGFloat {
        return 1.0
    }

    // MARK: - UIViewControllerPreviewingDelegate

    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let cell = didHitPhotoCell(location) {
            let rect = photoCellRect(IndexPath(item: cell.photoIndex, section: 0))
            previewingContext.sourceRect = rect

            return createPhotoPeekVC(cell.photoIndex)
        }

        return nil
    }

    func photoCellRect(_ indexPath: IndexPath) -> CGRect {
        var rect = photoGridView.collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? CGRect.zero
        rect = view.convert(rect, from: photoGridView.collectionView)

        return rect
    }

    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let peekVC = viewControllerToCommit as? PeekVCProtocol {
            peekVC.commitBlock?()
        }
    }

    private func didHitPhotoCell(_ point: CGPoint) -> HLPhotoScrollCollectionCell? {
        return view.hl_didHitViewOfClass(allowedClasses: [HLPhotoScrollCollectionCell.self], point: point) as? HLPhotoScrollCollectionCell
    }

    private func createPhotoPeekVC(_ photoIndex: Int) -> PhotoPeekVC {
        let peekVC = PhotoPeekVC(nibName: "PeekTableVC", bundle: nil)
        peekVC.photoIndex = photoIndex
        peekVC.variant = variant
        let width = UIScreen.main.bounds.width
        let height = peekVC.heightForVariant(variant, peekWidth: width)
        peekVC.preferredContentSize = CGSize(width: width, height: height)
        peekVC.commitBlock = {[weak self] in self?.photoCollectionViewDidSelectPhotoAtIndex(photoIndex) }

        return peekVC
    }
}
