import UIKit

class HLPriceTableHeaderView: HLGroupedTableHeaderView {
    @IBOutlet weak var offersLabel: UILabel!

    var offersCount: Int? {
        didSet {
            offersLabel.text = StringUtils.offersString(withCount: offersCount)
        }
    }

    override class func preferredHeight(_ hasTitle: Bool) -> CGFloat {
        return 70.0
    }
}
