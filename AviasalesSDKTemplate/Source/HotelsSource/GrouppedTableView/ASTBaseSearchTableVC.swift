import UIKit

class ASTBaseSearchTableVC: UITableViewController {

    var sections: [GroupedTableSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.hl_registerNib(withName: HLGroupedTableCell.hl_reuseIdentifier())
        tableView.hl_registerNib(withName: HLUserLocationTableCell.hl_reuseIdentifier())
        tableView.register(UINib(nibName: "HLGroupedTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HLGroupedTableHeaderView")
    }

    func goBack() {
        if iPhone() {
            _ = navigationController?.popViewController(animated: true)
        } else {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
