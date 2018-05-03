import UIKit

@IBDesignable class CancelableFilterViewCell: RootFilterViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    var stringFilterItem: StringFilterItem?

    override var defaultBackgroundColor: UIColor {
        return UIColor(hex: 0xEFF3F5)
    }

    override var selectedBackgroundColor: UIColor {
        return UIColor(hex: 0xEFF3F5)
    }

    override var defaultBorderWidth: CGFloat {
        return 0
    }

    override var selectedBorderWidth: CGFloat {
        return 0
    }

    override var defaultBorderColor: CGColor {
        return UIColor.clear.cgColor
    }

    override var selectedBorderColor: CGColor {
        return UIColor.clear.cgColor
    }

    override func configure(with item: StringFilterItem) {
        stringFilterItem = item
        titleLabel.text = item.text
    }

    override class func rect(for item: StringFilterItem) -> CGRect {
        var result = CGRect(x: 0, y: 0, width: 47, height: 34)
        if let textRectWidth = item.text?.hl_width(attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0)], height : 18) {
            result.size.width += textRectWidth
        }

        return result
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        delegate?.filterViewCellPressed(filterViewCell: self)
    }

    override func filterViewPressed(_ sender: RootFilterViewCell) {
    }
}
