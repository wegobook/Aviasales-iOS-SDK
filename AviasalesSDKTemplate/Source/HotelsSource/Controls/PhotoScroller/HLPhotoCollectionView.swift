import Foundation
import UIKit

@objc protocol HLPhotoCollectionViewDelegate: NSObjectProtocol {
    @objc optional func photoCollectionViewDidSelectPhotoAtIndex(_ index: Int)
    @objc optional func photoCollectionViewImageContentMode() -> UIViewContentMode
    @objc optional func photoCollectionViewPlacegolderContentMode() -> UIViewContentMode
}

class HLPhotoCollectionView: UIView {

    fileprivate(set) var collectionView: UICollectionView!

    weak var delegate: HLPhotoCollectionViewDelegate?

    var placeholderImage: UIImage?
    var currentPhotoIndex: Int = 0
    var content: [AnyObject] = []
    var thumbs: [URL] = []
    var needPrefetch: Bool = true
    var needUseThumbs: Bool = false

    var reuseCellIdentifier: String {
        return ""
    }

    var cellSize: CGSize = CGSize.zero

    // MARK: - Required methods

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Override methods

    override var bounds: CGRect {
        didSet {
            if !self.bounds.size.equalTo(oldValue.size) {
                self.relayoutContent()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.initialize()
    }

    // MARK: - Internal methods

    func initialize() {
        self.backgroundColor = UIColor.black
        self.layer.contentsGravity = kCAGravityCenter
        self.layer.masksToBounds = true

        self.cellSize = self.calculateCellSize()

        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.createCollectionViewLayout())
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.scrollsToTop = false
        self.collectionView.backgroundColor = UIColor.clear
        self.addSubview(self.collectionView)
        collectionView.autoPinEdgesToSuperviewEdges()
        self.setNeedsLayout()

    }

    func createCollectionViewLayout() -> UICollectionViewFlowLayout {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.minimumInteritemSpacing = 0.0
        collectionLayout.minimumLineSpacing = 0.0
        collectionLayout.sectionInset = UIEdgeInsets.zero
        collectionLayout.itemSize = cellSize
        return collectionLayout
    }

    func calculateCellSize() -> CGSize {
        return CGSize.zero
    }

    func calculateContentSize() -> CGSize {
        return CGSize.zero
    }

    func scrollToPhotoIndex(_ index: Int, animated: Bool) {
    }

    func relayoutContent() {
        cellSize = calculateCellSize()
        collectionView.delegate = nil
        collectionView.contentSize = calculateContentSize()
        collectionView.delegate = self
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = cellSize
        collectionView.collectionViewLayout.invalidateLayout()
        scrollToPhotoIndex(currentPhotoIndex, animated: false)
        layoutIfNeeded()
    }

}

extension HLPhotoCollectionView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.content.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCellIdentifier, for: indexPath) as! HLPhotoScrollCollectionCell

        if let contentMode = self.delegate?.photoCollectionViewPlacegolderContentMode?() {
            cell.placeholderContentMode = contentMode
        }

        if let contentMode = self.delegate?.photoCollectionViewImageContentMode?() {
            cell.imageContentMode = contentMode
        }

        let photoIndex = indexPath.item
        cell.photoIndex = photoIndex

        if let image = self.content[photoIndex] as? UIImage {
            cell.image = image
        } else if let url = self.content[photoIndex] as? URL {
            if self.thumbs.count > photoIndex {
                let thumbUrl = self.thumbs[photoIndex]
                cell.setImage(url: url, thumbUrl: thumbUrl, placeholder: placeholderImage, animated: true)
            } else {
                cell.setImage(url: url, placeholder: placeholderImage, animated: true)
            }
        }

        return cell
    }

}

extension HLPhotoCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.calculateCellSize()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.photoCollectionViewDidSelectPhotoAtIndex?((indexPath as NSIndexPath).item)
    }

}
