import UIKit

class HLNearbyCitiesSearchCardItem: HLActionCardItem {

    override init(topItem: Bool, cellReuseIdentifier: String, filter: Filter?, delegate: HLActionCellDelegate?) {
        super.init(topItem: topItem, cellReuseIdentifier: cellReuseIdentifier, filter: filter, delegate: delegate)
        height = 152.0
    }
}
