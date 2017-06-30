import UIKit

class HLPriceFilterCardItem: HLActionCardItem {
    var currency: HDKCurrency

    init(topItem: Bool, cellReuseIdentifier: String, filter: Filter, delegate: HLActionCellDelegate, currency: HDKCurrency) {
        self.currency = currency
        super.init(topItem: topItem, cellReuseIdentifier: cellReuseIdentifier, filter: filter, delegate: delegate)
    }
}
