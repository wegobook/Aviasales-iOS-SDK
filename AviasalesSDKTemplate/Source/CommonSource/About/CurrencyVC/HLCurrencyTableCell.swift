import UIKit

class HLCurrencyTableCell: UITableViewCell {

    @IBOutlet fileprivate weak var detailLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate(set) var markIcon: UIImageView!

    var marked = false {
        didSet {
            markIcon.isHidden = !marked
        }
    }

    var currency: HDKCurrency! {
        didSet {
            titleLabel.text = currency.code
            detailLabel.text = currency.text
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        markIcon.image = UIImage(named: "sortActiveIcon")!.imageTinted(with: JRColorScheme.navigationBarBackgroundColor())
    }
}

extension UITableView {

    func unmarkAllCells() {
        for cell in self.visibleCells {
            if let currencyCell = cell as? HLCurrencyTableCell {
                currencyCell.marked = false
            }
        }
    }
}
