import UIKit

class HLSectionFooterView: UIView {

    @IBOutlet weak var footerLabel: UILabel!

    fileprivate static let footerLabelFont = UIFont.systemFont(ofSize: 12.0)
    fileprivate static let verticalInset: CGFloat = 10.0
    fileprivate static let horizontalInset: CGFloat = 15.0

    static func calculateHeight(_ text: String, width: CGFloat) -> CGFloat {
        let textWidth = width - 2.0 * horizontalInset
        let textHeight = text.hl_height(attributes: [NSFontAttributeName: footerLabelFont], width: textWidth)

        return ceil(textHeight + verticalInset)
    }
}
