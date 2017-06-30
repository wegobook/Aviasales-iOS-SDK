import UIKit

class LocationSection: TableSection {
    override func headerHeight() -> CGFloat {
        let hasTitle = !(name?.isEmpty ?? true)
        return hasTitle ? 46 : 15
    }
}
