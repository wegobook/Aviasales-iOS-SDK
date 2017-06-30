import UIKit

class MultiAmenityFilterCell: HLDividerCell {

    private struct Consts {
        static let leftPadding: CGFloat = 15
        static let rightPadding: CGFloat = 15
        static let topPadding: CGFloat = 15
        static let bottomPadding: CGFloat = 15
    }
    @IBOutlet private weak var amenitiesView: CommonAmenityFilterView!
    var tableWidth: CGFloat?

    private (set) var filter: Filter!

    class func height(for tableWidth: CGFloat, with filter: Filter, amenityFilterItems: [StringFilterItem]) -> CGFloat {
        let leftAndRight = Consts.leftPadding + Consts.rightPadding
        let topAndBottom = Consts.topPadding + Consts.bottomPadding

        return CommonAmenityFilterView.height(for: tableWidth - leftAndRight, with: filter, amenityFilterItems: amenityFilterItems) + topAndBottom
    }

    func configure(with filter: Filter, and filterItems: [StringFilterItem]) {
        if let tableWidth = tableWidth {
            let leftAndRight = Consts.leftPadding + Consts.rightPadding
            amenitiesView.tableWidth = tableWidth - leftAndRight
        }
        amenitiesView.configure(with: filter, and: filterItems)
    }
}
