@objc protocol HLPhotoScrollViewDelegate: HLPhotoCollectionViewDelegate {

    @objc optional func photoScrollPhotoIndexChanged(_ index: Int)
    @objc optional func photoScrollWillBeginDragging()
    @objc optional func photoScrollDidEndDragging()
}

@objcMembers
class HLPhotoScrollView: HLPhotoCollectionView {

    static func preferredHeight() -> CGFloat {
        if iPhone35Inch() {
            return 150.0
        }
        if iPhone4Inch() {
            return 173.0
        }
        if iPhone47Inch() {
            return 204.0
        }
        if iPhone55Inch() {
            return 230.0
        }
        return 173.0
    }

    fileprivate let photosToPrefetchCount: Int = 1
    fileprivate var lockUpdateCurrentPhotoIndex: Bool = true

    fileprivate var photoScrollViewDelegate: HLPhotoScrollViewDelegate? {
        return self.delegate as? HLPhotoScrollViewDelegate
    }

    var visibleImage: UIImage? {
        let cell = self.collectionView?.visibleCells.last as? HLPhotoScrollCollectionCell

        return cell?.image
    }

    var visibleImageView: UIView? {
        let cell = self.collectionView?.visibleCells.last as? HLPhotoScrollCollectionCell

        return cell?.photoView.imageView
    }

    var visibleCell: UICollectionViewCell? {
        return self.collectionView.visibleCells.first
    }

    var contentTransform: CATransform3D = CATransform3DIdentity {
        didSet {
            for cell in self.collectionView.visibleCells {
                cell.layer.transform = self.contentTransform
            }
        }
    }

    // MARK: - Override methods

    override var reuseCellIdentifier: String {
        return "PhotoScrollCollectionCell"
    }

    override func initialize() {
        super.initialize()

        self.collectionView.register(HLPhotoScrollCollectionCell.self, forCellWithReuseIdentifier: self.reuseCellIdentifier)
        self.collectionView.isPagingEnabled = true
    }

    override func calculateCellSize() -> CGSize {
        return self.bounds.size
    }

    override func calculateContentSize() -> CGSize {
        return CGSize(width: self.cellSize.width * CGFloat(self.content.count), height: self.bounds.height)
    }

    override func scrollToPhotoIndex(_ index: Int, animated: Bool) {
        guard index < self.content.count else { return }

        super.scrollToPhotoIndex(index, animated: animated)

        let x = CGFloat(index) * self.cellSize.width
        self.collectionView.setContentOffset(CGPoint(x: x, y: 0.0), animated: animated)

        self.currentPhotoIndex = index
        self.prefetchNextPhotosIfNeeded()
    }

    // MARK: - Private methods

    fileprivate func changeCurrentPhotoIndex() {
        let count = self.content.count
        let modulo = self.collectionView.contentOffset.x.truncatingRemainder(dividingBy: self.cellSize.width)

        var index = Int(self.collectionView.contentOffset.x / self.cellSize.width)
        index += (modulo > self.cellSize.width / 2.0) ? 1 : 0
        index = min(max(0, index), count - 1)

        if self.currentPhotoIndex != index {
            self.currentPhotoIndex = index
            self.prefetchNextPhotosIfNeeded()

            self.photoScrollViewDelegate?.photoScrollPhotoIndexChanged?(index)
        }
    }

    fileprivate func prefetchNextPhotosIfNeeded() {
        if self.needPrefetch {
            for i in (self.currentPhotoIndex + 1)...(self.currentPhotoIndex + self.photosToPrefetchCount) {
                if i < self.content.count {
                    if let url = self.content[i] as? URL {
                        HLPhotoManager.sharedManager.downloadImage(url: url, target: nil)
                    }
                } else {
                    break
                }
            }
        }
    }

}

extension HLPhotoScrollView {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.lockUpdateCurrentPhotoIndex {
            self.changeCurrentPhotoIndex()
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lockUpdateCurrentPhotoIndex = false

        self.photoScrollViewDelegate?.photoScrollWillBeginDragging?()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lockUpdateCurrentPhotoIndex = !decelerate

        self.photoScrollViewDelegate?.photoScrollDidEndDragging?()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.lockUpdateCurrentPhotoIndex = true
    }

}
