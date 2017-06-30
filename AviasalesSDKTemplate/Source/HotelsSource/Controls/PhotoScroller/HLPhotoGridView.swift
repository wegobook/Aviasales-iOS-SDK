@objc protocol HLPhotoGridViewDelegate: HLPhotoCollectionViewDelegate {

    @objc optional func columnCount() -> Int
    @objc optional func columnInset() -> CGFloat

    @objc optional func photoGridViewCellDidSelect(_ cell: HLPhotoScrollCollectionCell)
    @objc optional func photoGridViewCellDidHighlight(_ cell: HLPhotoScrollCollectionCell)
}

class HLPhotoGridView: HLPhotoCollectionView, HLPhotoScrollCollectionCellProtocol {

    private let defaultColumnCount: Int = 3
    private let defaultColumnInset: CGFloat = 0.0

    private var photoGridViewDelegate: HLPhotoGridViewDelegate? {
        return self.delegate as? HLPhotoGridViewDelegate
    }

    // MARK: - Override methods

    override var reuseCellIdentifier: String {
        return "PhotoScrollCollectionCell"
    }

    override func initialize() {
        super.initialize()

        self.collectionView.register(HLPhotoScrollCollectionCell.self, forCellWithReuseIdentifier: self.reuseCellIdentifier)
        self.collectionView.isPagingEnabled = false
        self.collectionView.alwaysBounceHorizontal = false
        self.collectionView.alwaysBounceVertical = true
    }

    override func createCollectionViewLayout() -> UICollectionViewFlowLayout {
        let inset = photoGridViewDelegate?.columnInset?() ?? defaultColumnInset
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .vertical
        collectionLayout.minimumInteritemSpacing = inset
        collectionLayout.minimumLineSpacing = inset
        collectionLayout.sectionInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)

        return collectionLayout
    }

    override func calculateCellSize() -> CGSize {
        let inset = self.photoGridViewDelegate?.columnInset?() ?? self.defaultColumnInset
        let columnsCount = CGFloat(self.photoGridViewDelegate?.columnCount?() ?? self.defaultColumnCount)
        let width = (self.bounds.width - (columnsCount - 1.0) * inset) / columnsCount

        return CGSize(width: floor(width), height: floor(width))
    }

    override func calculateContentSize() -> CGSize {
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let rowInset = CGFloat(layout.minimumLineSpacing)
        let columnsCount = CGFloat(self.photoGridViewDelegate?.columnCount?() ?? self.defaultColumnCount)
        let columnInset = self.photoGridViewDelegate?.columnInset?() ?? self.defaultColumnInset
        let rowsCount = ceil(CGFloat(self.content.count) / columnsCount)
        let height = self.cellSize.height * rowsCount + rowInset * (rowsCount + 1.0)
        let width = self.cellSize.width * columnsCount + columnInset * (columnsCount - 1.0)

        return CGSize(width: ceil(width), height: ceil(height))
    }

    override func relayoutContent() {
        super.relayoutContent()

        let collectionLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let inset = self.photoGridViewDelegate?.columnInset?() ?? self.defaultColumnInset
        collectionLayout.minimumLineSpacing = inset
        collectionLayout.minimumInteritemSpacing = inset
        collectionLayout.sectionInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
    }

    // MARK: - Internal methods

    override func scrollToPhotoIndex(_ index: Int, animated: Bool) {
        guard index < self.content.count else { return }

        super.scrollToPhotoIndex(index, animated: animated)

        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let count = CGFloat(self.photoGridViewDelegate?.columnCount?() ?? self.defaultColumnCount)
        let row = Int(CGFloat(index) / count)
        let rowInset = layout.minimumLineSpacing
        let lim = max(0.0, self.collectionView.contentSize.height - self.collectionView.bounds.height)
        var y = CGFloat(row) * (rowInset + self.cellSize.height)
        y = min(ceil(y), lim)

        self.collectionView.setContentOffset(CGPoint(x: 0.0, y: y), animated: animated)
    }

    // MARK - HLPhotoScrollCollectionCellDelegate

    func cellDidSelect(_ cell: HLPhotoScrollCollectionCell) {
        self.photoGridViewDelegate?.photoGridViewCellDidSelect?(cell)
    }

    func cellDidHighlight(_ cell: HLPhotoScrollCollectionCell) {
        self.photoGridViewDelegate?.photoGridViewCellDidHighlight?(cell)
    }

}

extension HLPhotoGridView {

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! HLPhotoScrollCollectionCell
        cell.needShowProgressView = false
        cell.backgroundColor = JRColorScheme.hotelBackgroundColor()
        cell.delegate = self
        cell.applySelectedStyle(cell.isSelected)

        return cell
    }
}
