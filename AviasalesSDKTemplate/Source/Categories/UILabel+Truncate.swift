import UIKit

extension UILabel {
    func isTruncated() -> Bool {
        if let string = self.text {
            let calculatedHeight = string.hl_height(attributes: [NSFontAttributeName: self.font], width: self.bounds.size.width)

            return (calculatedHeight > self.bounds.size.height)
        }

        return false
    }
}
