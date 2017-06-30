import Foundation

extension UIImageView {

    func hl_setImageAndHideLabelWithFadeForUrl(_ url: URL, label: UIView, duration: TimeInterval = 0.3) {

        alpha = 0.0
        label.alpha = 1.0

        sd_setImage(with: url) { [weak self](image, error, cacheType, url) in
            if cacheType == .none {
                UIView.animate(withDuration: duration) {
                    self?.alpha = 1.0
                    label.alpha = 0.0
                }
            } else {
                self?.alpha = 1.0
                label.alpha = 0.0
            }
        }

    }
}
