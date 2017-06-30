import UIKit

class PackagingFilterView: RootFilterView {

    var filterViewCells: [RootFilterViewCell] = []

    private (set) var filterItems: [StringFilterItem] = []

    override func allFilterCells() -> [RootFilterViewCell] {
        return filterViewCells
    }

    func shouldRecreateSubviews() -> Bool {
        return true
    }

    func configure(with filter: Filter, and filterItems: [StringFilterItem]) {
        var cells: [RootFilterViewCell] = []

        if filterViewCells.count == 0 || shouldRecreateSubviews() {
            contentContainer.removeAllSubviews()

            for item in filterItems {
                let cell = self.cell(frame: CGRect.zero)
                cell.configure(with: item)
                cell.frame = type(of: cell).rect(for: item)
                contentContainer?.addSubview(cell)
                cells.append(cell)
            }

            filterViewCells = cells
        }
        UIView.packViews(filterViewCells, widthLimit: tableWidth ?? bounds.width, rowOffset: 8, horizontalOffset: 8, shouldSort: false)
        configure(with: filter)
    }

    func cell(frame: CGRect) -> RootFilterViewCell {
        return RootFilterViewCell(frame: frame)
    }
}
