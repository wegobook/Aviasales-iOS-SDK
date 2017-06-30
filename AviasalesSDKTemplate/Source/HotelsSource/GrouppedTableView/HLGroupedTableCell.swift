import UIKit

class HLGroupedTableCell: UITableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var detailsLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet fileprivate weak var verticalCenterConstraint: NSLayoutConstraint!

    var showDetailsLabel: Bool = false {
        didSet {
            self.updateControl()
        }
    }

    var title: String? {
        didSet {
            self.updateControl()
        }
    }

    var details: String? {
        didSet {
            self.updateControl()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        updateControl()

        titleLabel.clipsToBounds = false
    }

    fileprivate func updateControl() {
        titleLabel.text = title
        detailsLabel.text = details

        let constraint = (self.showDetailsLabel ? ceil(self.detailsLabel.bounds.size.height / 2.0) : 0.0)
        verticalCenterConstraint.constant = constraint
        detailsLabel.isHidden = !self.showDetailsLabel

        setNeedsLayout()
        layoutIfNeeded()
    }

    func setupWithItem(_ item: GroupedTableItem) {
        title = item.title
        showDetailsLabel = false
        icon.image = item.icon
    }
}
