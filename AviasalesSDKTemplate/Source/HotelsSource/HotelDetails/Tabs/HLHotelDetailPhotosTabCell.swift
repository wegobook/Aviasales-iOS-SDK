class HLHotelDetailPhotosTabCell: HLHotelDetailsTabCell, HLPhotoGridViewDelegate {

    var photoGrid: HLPhotoGridView!

    var hotel: HDKHotel! {
        didSet {
            setupContent()
        }
    }

    override func createTabContentViewAndScrollView() -> (UIView, UIScrollView) {
        let photoGrid = HLPhotoGridView(frame:CGRect.zero)
        photoGrid.translatesAutoresizingMaskIntoConstraints = false
        photoGrid.backgroundColor = UIColor.clear
        photoGrid.delegate = self
        photoGrid.collectionView.scrollsToTop = false

        self.photoGrid = photoGrid
        return (photoGrid, photoGrid.collectionView)
    }

    func setupContent() {
        let thumbSize = HLPhotoManager.calculateThumbSizeForColumnsCount(delegate?.photosColumnsCount() ?? 1, containerWidth: bounds.width)
        photoGrid.updateDataSource(withHotel: hotel, imageSize: thumbSize, thumbSize: thumbSize, useThumbs: true)
    }

    func setSelectedStyleForPhotoIndex(_ photoIndex: Int) {
        photoGrid.collectionView.selectItem(at: IndexPath(item: photoIndex, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
    }

    // MARK: - Public

    func photoCellRect(_ indexPath: IndexPath) -> CGRect {
        var rect = photoGrid.collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? CGRect.zero
        rect = convert(rect, from: photoGrid.collectionView)

        return rect
    }

    // MARK: HLPhotoGridView delegate

    func columnCount() -> Int {
        return delegate?.photosColumnsCount() ?? 0
    }

    func columnInset() -> CGFloat {
        return 1.0
    }

    func photoCollectionViewDidSelectPhotoAtIndex(_ index: Int) {
        delegate?.showPhotoAtIndex(index)
    }

    func photoGridViewCellDidSelect(_ cell: HLPhotoScrollCollectionCell) {
        delegate?.photoGridViewCellDidSelect?(cell)
    }

    func photoGridViewCellDidHighlight(_ cell: HLPhotoScrollCollectionCell) {
        delegate?.photoGridViewCellDidHighlight?(cell)
    }

}
