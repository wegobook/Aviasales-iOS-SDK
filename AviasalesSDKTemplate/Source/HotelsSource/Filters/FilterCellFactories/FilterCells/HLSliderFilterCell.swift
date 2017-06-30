import UIKit

class HLSliderFilterCell: HLDividerCell {
    var notifyOnValueChanged = false

    func notifyDelegate() {
        // Implement in subclass
    }

    func sliderValueChanged(_ sender: AnyObject, event: UIEvent) {

        if let touchEvent = event.allTouches?.first, touchEvent.phase == .ended {
            sliderEditingDidEnd()
        } else if notifyOnValueChanged {
            notifyDelegate()
        }
    }

    func sliderEditingDidEnd() {
        notifyDelegate()
    }
}
