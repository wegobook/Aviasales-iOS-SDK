import Foundation

public extension UIView {
    func removeAllSubviews() {
        let subviewsToRemove = self.subviews
        for view in subviewsToRemove {
            view.removeFromSuperview()
        }
    }

    @discardableResult
    func addBlurEffect(with style: UIBlurEffectStyle) -> UIVisualEffectView {
        backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        addSubview(blurEffectView)
        blurEffectView.autoPinEdgesToSuperviewEdges()
        sendSubview(toBack: blurEffectView)

        return blurEffectView
    }

    func hl_didHitViewOfClass(allowedClasses: [UIView.Type], point: CGPoint) -> UIView? {
        var hitView = hitTest(point, with: nil)
        while hitView != nil {
            if allowedClasses.contains(where: { $0 == type(of: hitView!) }) {
                return hitView
            }
            hitView = hitView?.superview
        }

        return nil
    }
}
