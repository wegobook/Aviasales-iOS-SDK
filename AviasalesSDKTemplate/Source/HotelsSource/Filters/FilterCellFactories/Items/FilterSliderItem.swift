import UIKit

class FilterSliderItem: TableItem {

    var filter: Filter
    weak var controlDelegate: FilterControlDelegate?

    init(filter: Filter, controlDelegate: FilterControlDelegate?) {
        self.filter = filter
        self.controlDelegate = controlDelegate
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return 77.0
    }
}
