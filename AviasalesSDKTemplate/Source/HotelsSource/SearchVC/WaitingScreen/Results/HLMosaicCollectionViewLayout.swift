protocol HLMosaicCollectionViewLayoutItemsProtocol: NSObjectProtocol {
    func currentItemsInSection(_ section: Int) -> [HLCollectionItem]
}

class HLMosaicCollectionViewLayout: UICollectionViewFlowLayout {

    fileprivate var contentSize: CGSize!
    fileprivate var lastCollectionViewSize: CGSize = CGSize.zero
    fileprivate var layoutAttributes: [IndexPath : UICollectionViewLayoutAttributes]!

    weak var itemsDelegate: HLMosaicCollectionViewLayoutItemsProtocol?

    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributesInRect = [UICollectionViewLayoutAttributes]()

        for (_, value) in self.layoutAttributes {
            if rect.intersects(value.frame) {
                layoutAttributesInRect.append(value)
            }
        }

        return layoutAttributesInRect
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributes?[indexPath]
    }

    override func prepare() {
        relayoutScheme()
        lastCollectionViewSize = collectionView?.bounds.size ?? CGSize.zero

        super.prepare()
    }

    func relayoutScheme() {

    }

    func invalidateIfCollectionSizeChanged() {
        let newSize = collectionView?.bounds.size ?? CGSize.zero
        if lastCollectionViewSize != newSize {
            lastCollectionViewSize = collectionView?.bounds.size ?? CGSize.zero

            invalidateLayout()
        }
    }
}

class HLResultsMosaicCollectionViewLayout: HLMosaicCollectionViewLayout {

    // MARK: - Override methods

    override func relayoutScheme() {

        super.relayoutScheme()

        let scheme = ResultsCellsScheme.init(tableSize: collectionView?.frame.size)

        let sectionsCount = self.collectionView!.numberOfSections
        var newLayoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
        var contentHeight: CGFloat = 0.0
        var y: CGFloat = 0.0

        for section in 0..<sectionsCount {
            let collectionViewItemsCount = self.collectionView!.numberOfItems(inSection: section)
            let items = itemsDelegate?.currentItemsInSection(section) ?? []

            guard items.count == collectionViewItemsCount else {
                assertionFailure("items count from delegate and collection view are different")
                return
            }

            y += self.sectionInset.top

            var variantsLayoutModulo = 0
            var lastYInVariantsLayout: CGFloat = 0.0
            let variantsLayoutRowSize = scheme.rowSize

            for itemIndex in 0..<items.count {

                let item = items[itemIndex]
                let indexPath = IndexPath(item: itemIndex, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                var frame: CGRect = CGRect.zero

                if item as? HLVariantItem != nil {
                    frame = scheme.cellFrame(itemIndex: variantsLayoutModulo)
                    let x = frame.minX + self.sectionInset.left
                    attributes.frame = CGRect(x: x, y: y + frame.minY, width: frame.width, height: frame.height)

                    if (variantsLayoutModulo + 1) % scheme.frames.count == 0 {
                        y += (self.minimumLineSpacing + variantsLayoutRowSize.height)
                        lastYInVariantsLayout = 0.0
                    } else {
                        lastYInVariantsLayout = frame.maxY
                    }
                    variantsLayoutModulo += 1
                } else if let cardItem = item as? HLActionCardItem {
                    y += lastYInVariantsLayout
                    lastYInVariantsLayout = 0.0
                    variantsLayoutModulo = 0
                    frame = scheme.cardFrame
                    let x = frame.minX + self.sectionInset.left
                    attributes.frame = CGRect(x: x, y: y + frame.minY, width: frame.width, height: cardItem.height)
                    y += (self.minimumLineSpacing + cardItem.height)
                }

                contentHeight = max(attributes.frame.maxY, contentHeight)
                newLayoutAttributes[indexPath] = attributes
            }

            y += self.sectionInset.bottom
        }

        let height = self.collectionView!.bounds.height
        let width = self.collectionView!.bounds.width

        contentHeight += self.sectionInset.bottom
        contentHeight = (contentHeight < height) ? height : contentHeight

        self.layoutAttributes = newLayoutAttributes
        self.contentSize = CGSize(width: width, height: contentHeight)
    }
}

// MARK: - ResultsCellsScheme class

class ResultsCellsScheme {

    let defaultInset: CGFloat = 5.0
    let bigCellRatio: CGFloat = 0.543
    let smallCellRatio: CGFloat = 0.583
    var rowSize: CGSize = CGSize(width: 100.0, height: 100.0)
    var bigRowWidth: CGFloat = 0.0
    var bigRowHeight: CGFloat =  0.0
    var smallLeftRowWidth: CGFloat = 0.0
    var smallRightRowWidth: CGFloat  = 0.0
    var smallRowHeight: CGFloat = 0.0
    var frames: [CGRect] = []
    var cardFrame: CGRect = CGRect.zero

    var tableWidth: CGFloat = 0.0

    init(tableSize: CGSize?) {
        tableWidth = max((tableSize?.width ?? 0.0) - 2 * defaultInset, 0.0)
        bigRowWidth = floor(tableWidth - 1.0)
        bigRowHeight = floor(bigCellRatio * bigRowWidth)
        smallLeftRowWidth = floor((bigRowWidth - defaultInset) / 2.0)
        smallRightRowWidth = floor((bigRowWidth - defaultInset) / 2.0)
        smallRowHeight = floor(smallCellRatio * smallLeftRowWidth)
        rowSize = CGSize(width: bigRowWidth, height: 2 * defaultInset + bigRowHeight + 2 * smallRowHeight)

        frames = [CGRect(x: 0.0, y: 0.0, width: smallLeftRowWidth, height: smallRowHeight),
                  CGRect(x: defaultInset + smallLeftRowWidth, y: 0.0, width: smallRightRowWidth, height: smallRowHeight),
                  CGRect(x: 0.0, y: defaultInset + smallRowHeight, width: smallLeftRowWidth, height: smallRowHeight),
                  CGRect(x: defaultInset + smallLeftRowWidth, y: defaultInset + smallRowHeight, width: smallRightRowWidth, height: smallRowHeight),
                  CGRect(x: 0.0, y: 2 * (defaultInset + smallRowHeight), width: bigRowWidth, height: bigRowHeight)]
        cardFrame = CGRect(x: 0.0, y: 0.0, width: bigRowWidth, height: 200.0)
    }

    func cellFrame(itemIndex index: Int) -> CGRect {
        if frames.count > 0 {
            let frame = frames[index % frames.count]
            return frame
        }

        return CGRect.zero
    }
}
