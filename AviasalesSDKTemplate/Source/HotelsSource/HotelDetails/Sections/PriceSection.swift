class PriceSection: TableSection {

    private let kMaxPlainCount = 4
    let kCollapsedCount = 3
    var rooms: [HDKRoom] = []
    var variant: HLResultVariant
    var shouldShowSeparator = true {
        didSet {
            items = createItems(rooms, collapsedSize: kCollapsedCount, maxPlainSize: kMaxPlainCount, expanded: expanded)
        }
    }

    var expanded: Bool = true {
        didSet {
            items = createItems(rooms, collapsedSize: kCollapsedCount, maxPlainSize: kMaxPlainCount, expanded: expanded)
        }
    }

    init(rooms: [HDKRoom], name: String, variant: HLResultVariant) {
        self.rooms = rooms
        self.variant = variant
        self.expanded = false
        super.init(name: name, items: [])
        self.items = createItems(rooms, collapsedSize: kCollapsedCount, maxPlainSize: kMaxPlainCount, expanded: expanded)
    }

    override func headerView() -> UIView {
        let headerView = super.headerView() as! HLPriceTableHeaderView
        headerView.offersCount = rooms.count
        return headerView
    }

    override func headerHeight() -> CGFloat {
        let hasTitle = !(name?.isEmpty ?? true)
        return HLPriceTableHeaderView.preferredHeight(hasTitle)
    }

    override func headerNibName() -> String {
        return "HLPriceTableHeaderView"
    }

    func createItems(_ rooms: [HDKRoom], collapsedSize: Int, maxPlainSize: Int, expanded: Bool) -> [TableItem] {
        var result: [TableItem] = []

        if rooms.count > maxPlainSize {
            let count = expanded ? rooms.count : collapsedSize
            for i in 0..<count {
                let room = rooms[i]
                let currency = variant.searchInfo.currency
                let duration = variant.duration
                let canHighlightPrivatePrice = (room == variant.roomWithMinPrice)
                let item = RoomItem(room: room, currency: currency, duration: duration, canHighlightPrivatePrice: canHighlightPrivatePrice)
                item.shouldShowSeparator = false
                result.append(item)
            }
            result.append(ExpandPriceItem(section: self))
        } else {
            for i in 0..<rooms.count {
                let room = rooms[i]
                let currency = variant.searchInfo.currency
                let duration = variant.duration
                let canHighlightPrivatePrice = (room == variant.roomWithMinPrice)
                let item = RoomItem(room: room, currency: currency, duration: duration, canHighlightPrivatePrice: canHighlightPrivatePrice)
                item.shouldShowSeparator = false
                result.append(item)
            }

            (result.last as? RoomItem)?.shouldShowSeparator = shouldShowSeparator
            (result.last as? ExpandPriceItem)?.shouldShowSeparator = shouldShowSeparator
        }

        TableItem.setFirstAndLast(items: result)

        return result
    }

}
