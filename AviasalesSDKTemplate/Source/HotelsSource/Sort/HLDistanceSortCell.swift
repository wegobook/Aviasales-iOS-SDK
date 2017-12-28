import UIKit

class HLDistanceSortCell: HLSortCell {

    @IBOutlet weak var pointButton: UIButton!
    weak var pointSelectionDelegate: PointSelectionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        pointButton.setTitleColor(JRColorScheme.actionColor(), for: UIControlState())
        pointButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
    }

    @IBAction private func openPointSelectionScreen() {
        pointSelectionDelegate?.openPointSelectionScreen()
    }
}
