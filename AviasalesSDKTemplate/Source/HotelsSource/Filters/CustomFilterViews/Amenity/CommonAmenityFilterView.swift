import UIKit

class CommonAmenityFilterView: PackagingFilterView {

    override func nibName() -> String {
        return "AmenityFilterView"
    }

    override func shouldRecreateSubviews() -> Bool {
        return false
    }

    class func height(for tableWidth: CGFloat, with filter: Filter, amenityFilterItems: [StringFilterItem]) -> CGFloat {
        var rects: [CGRect] = []

        for item in amenityFilterItems {
            let rect = AmenityFilterViewCell.rect(for: item)
            rects.append(rect)
        }

        let resultHeight = UIView.packRects(rects, widthLimit: tableWidth, rowOffset: 8, horizontalOffset: 8, shouldSort: false)

        return resultHeight
    }

    override func filterViewCellPressed(filterViewCell: RootFilterViewCell) {
        super.filterViewCellPressed(filterViewCell: filterViewCell)

        if let amenityFilterViewCell = filterViewCell as? AmenityFilterViewCell, let filterItem = amenityFilterViewCell.amenityFilterItem {

            filterItem.changeValue(for: filter)
            filter.filter()
        }
    }

    override func cellShouldBeSelected(cell: RootFilterViewCell) -> Bool {
        if let amenityFilterViewCell = cell as? AmenityFilterViewCell, let filterItem = amenityFilterViewCell.amenityFilterItem {
            return filterItem.isSelected(for: filter)
        }

        return super.cellShouldBeSelected(cell: cell)
    }

    override func cell(frame: CGRect) -> RootFilterViewCell {
        return AmenityFilterViewCell(frame: frame)
    }

}
