@objcMembers
class ActionCardsConfiguration: NSObject {

    var searchInfo: HLSearchInfo
    var filter: Filter
    var delegate: HLActionCellDelegate

    init(searchInfo: HLSearchInfo, filter: Filter, delegate: HLActionCellDelegate) {
        self.searchInfo = searchInfo
        self.filter = filter
        self.delegate = delegate
    }
}
