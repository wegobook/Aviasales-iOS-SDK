import UIKit

class HLBadgeIconView: UIView {
    @IBOutlet fileprivate weak var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }
}
