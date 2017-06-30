import UIKit

class WaitingOtherGatesCell: WaitingCell {

    @IBOutlet private weak var textLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()

        textLabel?.text = NSLS("HL_WAITING_SCREEN_OTHERWEBSITES")
    }

}
