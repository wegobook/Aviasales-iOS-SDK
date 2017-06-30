import UIKit

@IBDesignable class StarsFilterView: RootFilterView {

    @IBOutlet var oneStarFilterViewCell: StarFilterViewCell!
    @IBOutlet var twoStarsFilterViewCell: StarFilterViewCell!
    @IBOutlet var threeStarsFilterViewCell: StarFilterViewCell!
    @IBOutlet var fourStarsFilterViewCell: StarFilterViewCell!
    @IBOutlet var fiveStarsFilterViewCell: StarFilterViewCell!

    override func allFilterCells() -> [RootFilterViewCell] {
        return [oneStarFilterViewCell, twoStarsFilterViewCell, threeStarsFilterViewCell, fourStarsFilterViewCell, fiveStarsFilterViewCell]
    }

    override func filterViewCellPressed(filterViewCell: RootFilterViewCell) {
        super.filterViewCellPressed(filterViewCell: filterViewCell)

        if let starFilterViewCell = filterViewCell as? StarFilterViewCell, let index = allFilterCells().index(of: starFilterViewCell) {
            let star = index + 1
            if filter.stars.contains(star) {
                filter.stars.remove(star)
            } else {
                _ = filter.stars.insert(star)
            }
            filter.filter()
        }
    }

    override func configure(with filter: Filter) {
        for i in 0..<allFilterCells().count {
            if let starFilterViewCell = allFilterCells()[i] as? StarFilterViewCell {
                starFilterViewCell.numberOfStars = i + 1
            }
        }

        super.configure(with: filter)
    }

    override func cellShouldBeSelected(cell: RootFilterViewCell) -> Bool {
        if let starFilterViewCell = cell as? StarFilterViewCell, let index = allFilterCells().index(of: starFilterViewCell) {
            return filter.stars.contains(index + 1)
        }

        return super.cellShouldBeSelected(cell: cell)
    }
}
