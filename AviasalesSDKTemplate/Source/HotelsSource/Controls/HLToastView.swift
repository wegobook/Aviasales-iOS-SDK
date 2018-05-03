import UIKit
import Foundation

@objcMembers
class HLToastView: UIView {

    var presented: Bool = false
	var animated: Bool = false
    var needHideByTimeout: Bool = true
    var hideAfterTime: TimeInterval = 1.0

    fileprivate let defaultWidth: CGFloat = 240.0
    fileprivate let defaultShowDuration: TimeInterval = 0.4
    fileprivate let defaultHideDuration: TimeInterval = 0.8

    fileprivate var hideTimer: Timer?

    @IBOutlet fileprivate(set) weak var iconView: UIImageView!
    @IBOutlet fileprivate(set) weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.initialize()
    }

    // MARK: - Internal methods

    func show(_ onView: UIView, animated: Bool) {
        onView.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.alpha = 0.0

        let constraintWidth = NSLayoutConstraint.constraints(withVisualFormat: "H:[selfView(selfWidth)]", options: .alignAllCenterY, metrics: ["selfWidth": defaultWidth], views: ["selfView": self])
        onView.addConstraints(constraintWidth)
        let constraintCenterY = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: 0)
        onView.addConstraint(constraintCenterY)
        let constraintCenterX = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0)
        onView.addConstraint(constraintCenterX)

        let duration = (animated ? self.defaultShowDuration : 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.alpha = 1.0
            }, completion: { (finished) -> Void in
                if self.needHideByTimeout {
                    self.hideTimer = Timer.scheduledTimer(timeInterval: self.hideAfterTime, target: self, selector: #selector(HLToastView.onTimer), userInfo: nil, repeats: false)
                }
        })

        self.presented = true
    }

    func dismiss(_ duration: TimeInterval) {
        if self.animated {
			return
		}

		self.animated = true

		let options: UIViewAnimationOptions = UIViewAnimationOptions.beginFromCurrentState

        UIView.animate(withDuration: duration, delay: 0.0, options: options,
            animations: { () -> Void in
                self.alpha = 0.0
            }, completion: { (finished) -> Void in
                self.removeFromSuperview()
                self.presented = false
                self.animated = false
        })
    }

	func timeredDismiss() {
		self.dismiss(0.8)
	}

	func manualDismiss() {
		self.dismiss(0.3)
	}

    @objc func onTimer() {
        self.timeredDismiss()
    }

    // MARK: - Private methods

    fileprivate func initialize() {
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
    }

}
