import UIKit

class StarFilterCell: HLDividerCell {
    private (set) var filter: Filter!
    @IBOutlet private weak var starsFilterView: StarsFilterView!

    func configure(with filter: Filter) {
        starsFilterView.configure(with: filter)
    }
}
