class HLActionCardItem: HLCollectionItem {

    var height: CGFloat = 0.0
    var topItem: Bool = false
    var filter: Filter?
    weak var delegate: HLActionCellDelegate?
    var cellReuseIdentifier: String

    init(topItem: Bool, cellReuseIdentifier: String, filter: Filter?, delegate: HLActionCellDelegate?) {
        self.filter = filter
        self.cellReuseIdentifier = cellReuseIdentifier
        self.delegate = delegate
        self.topItem = topItem
        height = topItem ? 76.0 : 107.0
    }

    override func isEqual(_ object: Any?) -> Bool {
        let objectCardItem = object as? HLActionCardItem

        return objectCardItem != nil && objectCardItem?.filter == filter && cellReuseIdentifier == objectCardItem?.cellReuseIdentifier
    }

    override var hash: Int {
        let filterHash = filter?.hash ?? 0
        return cellReuseIdentifier.hash ^ filterHash
    }

}
