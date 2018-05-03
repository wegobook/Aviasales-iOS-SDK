import UIKit

@objcMembers
class HLPopularHotelBadge: NSObject {
    var name: String?
    var systemName: String?
    var color: UIColor?
    override func isEqual(_ object: Any?) -> Bool {
        return self.systemName == (object as? HLPopularHotelBadge)?.systemName
    }
}
