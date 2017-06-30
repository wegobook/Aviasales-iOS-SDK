import UIKit

class SelectionFilterCell: HLDividerCell {

    @IBOutlet weak var customAccessoryView: UIImageView!
    @IBOutlet weak var titleLeftConstraint: NSLayoutConstraint!
    @IBOutlet var titleToAccessoryViewConstraint: NSLayoutConstraint?

    var checkboxOnImage: UIImage? {
        return UIImage(named:"filterCheckboxOn")
    }

    var checkboxOffImage: UIImage? {
        return UIImage(named:"filterCheckboxOff")
    }

    var active: Bool = false {
        didSet {
            updateActiveState()
        }
    }

    func updateActiveState() {
        customAccessoryView.image = active ? checkboxOnImage : checkboxOffImage
    }

    func setup(_ item: FilterSelectionItem) {
        active = item.active
        titleLabel.text = item.title
        item.cell = self
    }
}
