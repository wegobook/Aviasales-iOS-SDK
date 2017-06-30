import Foundation

class RightSideImageButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()

        let transform = CGAffineTransform(scaleX: -1, y: 1)
        self.transform = transform
        self.titleLabel?.transform = transform
        self.imageView?.transform = transform
    }
}
