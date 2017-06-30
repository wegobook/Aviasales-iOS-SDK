import UIKit

class HLUserLocationTableCell: HLGroupedTableCell {

    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!

    func setActive(_ active: Bool) {
        if active {
            activityIndicator.startAnimating()
            icon.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            icon.isHidden = false
        }
    }
}
