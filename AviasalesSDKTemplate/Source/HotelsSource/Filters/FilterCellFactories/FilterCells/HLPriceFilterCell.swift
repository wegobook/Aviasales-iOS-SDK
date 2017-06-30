import UIKit

class HLPriceFilterCell: HLDividerCell, PriceFilterViewDelegate {

    @IBOutlet weak var priceFilterView: PriceFilterView!

    var currency: HDKCurrency?
    var filter: Filter?

    func setSliderThumbs() {
        priceFilterView.configure(withFilter: filter!)
        priceFilterView.delegate = self
    }

    // MARK: - PriceFilterViewDelegate methods

    func filterApplied() {
        let minPrice = filter!.currentMinPrice
        let maxPrice = filter!.currentMaxPrice
        filterControlDelegate?.didUpdatePrice?(minPrice, maxPrice: maxPrice)
    }

}
