import UIKit

class PagesView: UICollectionView {

    typealias GestureFilterFunc = (_ view: UIView, _ gestureRecognizer: UIGestureRecognizer) -> Bool

    var shouldPreventGestureRecognizerBegining: GestureFilterFunc = { (view, _) in
        return (view is UISlider) || (view is HLRangeSlider)
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        if let subview = hitTest(point, with: nil) {
            if shouldPreventGestureRecognizerBegining(subview, gestureRecognizer) {
                return false
            }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
