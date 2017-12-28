import UIKit

@IBDesignable class AmenityFilterViewCell: RootFilterViewCell {

    @IBOutlet weak var titleLabel: UILabel?

    var amenityFilterItem: StringFilterItem?

    override var selectedBackgroundColor: UIColor {
        return JRColorScheme.mainColor()
    }

    override var isSelected: Bool {
        didSet {
            titleLabel?.textColor = isSelected ? UIColor.white : JRColorScheme.darkTextColor()
        }
    }

    override func configure(with item: StringFilterItem) {
        amenityFilterItem = item
        if let titleLabel = titleLabel {
            titleLabel.text = item.text
        }
    }

    override class func rect(for item: StringFilterItem) -> CGRect {
        var result = CGRect(x: 0, y: 0, width: 30, height: 34)
        let font = UIFont.systemFont(ofSize: 15.0)
        if let textRectWidth = item.text?.hl_width(attributes: [NSFontAttributeName: font], height : 18) {
            result.size.width += textRectWidth
        }

        return result
    }
}
