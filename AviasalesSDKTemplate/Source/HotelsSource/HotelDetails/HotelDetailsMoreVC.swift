import UIKit

class HotelDetailsMoreVC: HLCommonVC {
    let variant: HLResultVariant

    init(variant: HLResultVariant, nibName: String) {
        self.variant = variant
        super.init(nibName: nibName, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
