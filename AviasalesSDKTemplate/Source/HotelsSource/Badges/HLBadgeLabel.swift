import UIKit

class HLBadgeLabel: UILabel {
    let iconLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(iconLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, self.insets))
    }

    func configure(forIcon icon: UIImage) {
        iconLayer.contents = icon.cgImage
        iconLayer.frame = CGRect(x: 0.0, y: (self.bounds.height - icon.size.height) / 2.0, width: icon.size.width, height: icon.size.height)
        iconLayer.contentsScale = icon.scale
    }
}
