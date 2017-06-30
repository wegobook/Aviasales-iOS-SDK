import UIKit

@objc protocol DummyCancelableFilterViewCellDelegate: NSObjectProtocol {
    func dummyCancelableFilterViewCellPressed(dummyViewCell: CancelableFilterViewCell)
}

@objc protocol CancelableFilterViewDelegate: NSObjectProtocol {
    func cancelableFilterViewCellPressed(viewCell: CancelableFilterViewCell)
}

class CancelableFilterView: PackagingFilterView {

    weak var dummyDelegate: DummyCancelableFilterViewCellDelegate?
    weak var cancelableDelegate: CancelableFilterViewDelegate?

    override func nibName() -> String {
        return "CancelableFilterView"
    }

    class func height(for tableWidth: CGFloat, with filter: Filter, stringFilterItems: [StringFilterItem]) -> CGFloat {
        var rects: [CGRect] = []

        for item in stringFilterItems {
            let rect = CancelableFilterViewCell.rect(for: item)
            rects.append(rect)
        }

        let resultHeight = UIView.packRects(rects, widthLimit: tableWidth, rowOffset: 8, horizontalOffset: 8, shouldSort: false)

        return resultHeight
    }

    override func filterViewCellPressed(filterViewCell: RootFilterViewCell) {
        super.filterViewCellPressed(filterViewCell: filterViewCell)

        if let cancelableFilterViewCell = filterViewCell as? CancelableFilterViewCell, let filterItem = cancelableFilterViewCell.stringFilterItem {
            guard type(of: filterItem) != DummyFilterItem.self else {
                dummyDelegate?.dummyCancelableFilterViewCellPressed(dummyViewCell: cancelableFilterViewCell)
                return
            }

            filterItem.changeValue(for: filter)
            filter.filter()
            cancelableDelegate?.cancelableFilterViewCellPressed(viewCell: cancelableFilterViewCell)
        }
    }

    override func cell(frame: CGRect) -> RootFilterViewCell {
        return CancelableFilterViewCell(frame: frame)
    }
}
