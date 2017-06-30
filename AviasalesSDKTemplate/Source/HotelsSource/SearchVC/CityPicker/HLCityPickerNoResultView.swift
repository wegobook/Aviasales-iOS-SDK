import UIKit

class HLCityPickerNoResultView: UIView {

    @IBOutlet fileprivate weak var titleLabel: UILabel!

    func switchToNoResultsState() {
        titleLabel.text = NSLS("HL_LOC_NO_SEARCH_RESULTS")
    }

    func switchToNoInternetConnectionState() {
        titleLabel.text = NSLS("HL_ALERT_NO_INTERNET_CONNECTION_DESCRIPTION")
    }
}
