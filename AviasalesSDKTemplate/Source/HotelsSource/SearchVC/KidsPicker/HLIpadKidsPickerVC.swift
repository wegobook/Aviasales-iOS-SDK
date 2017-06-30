import UIKit

class HLIpadKidsPickerVC: HLKidsPickerVC {

    override func updateControls() {
        super.updateControls()

        delegate?.kidsSelected()
    }
}
