import UIKit

class ASTSearchResultsVC: ASTBaseSearchTableVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
}
