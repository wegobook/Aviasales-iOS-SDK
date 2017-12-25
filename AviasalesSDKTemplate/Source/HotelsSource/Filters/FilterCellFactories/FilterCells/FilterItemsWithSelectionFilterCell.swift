import UIKit

class FilterItemsWithSelectionFilterCell: HLDividerCell {

    private struct Consts {
        static let leftPadding: CGFloat = 15
        static let rightPadding: CGFloat = 15
        static let topPadding: CGFloat = 15
        static let bottomPadding: CGFloat = 15
        static let chooseButtonToFilterViewOffset: CGFloat = 15
        static let chooseButtonHeight: CGFloat = 20
    }

    @IBOutlet weak var chooseButton: UIButton!
    var chooseButtonPressedAction: (() -> Void)?

    @IBAction func chooseButtonPressed() {
        chooseButtonPressedAction?()
    }

    @IBOutlet weak var cancelableFilterView: CancelableFilterView!
    var tableWidth: CGFloat?

    private (set) var filter: Filter!

    class func height(for tableWidth: CGFloat, with filter: Filter, stringFilterItems: [StringFilterItem]) -> CGFloat {
        let leftAndRight = Consts.leftPadding + Consts.rightPadding
        let topAndBottom = Consts.topPadding + Consts.bottomPadding
        let cancelableFilterViewHeight = CancelableFilterView.height(for: tableWidth - leftAndRight, with: filter, stringFilterItems: stringFilterItems)
        let chooseButton = Consts.chooseButtonHeight + (cancelableFilterViewHeight > 0 ? Consts.chooseButtonToFilterViewOffset : 0)

        return cancelableFilterViewHeight + topAndBottom + chooseButton
    }

    func configure(with filter: Filter, and filterItems: [StringFilterItem]) {
        if let tableWidth = tableWidth {
            let leftAndRight = Consts.leftPadding + Consts.rightPadding
            cancelableFilterView.tableWidth = tableWidth - leftAndRight
        }
        cancelableFilterView.configure(with: filter, and: filterItems)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        chooseButton.setTitleColor(JRColorScheme.actionColor(), for: .normal)
    }

}
