@objc protocol FilterControlDelegate: NSObjectProtocol {
    @objc optional func didChangeMinimalRating(_ rating: Int)
    @objc optional func didChangeMaximumDistance(_ distance: CGFloat)
    @objc optional func didUpdatePrice(_ minPrice: Float, maxPrice: Float)
    @objc optional func openNameFilterScreen()
}

class HLDividerCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    weak var filterControlDelegate: FilterControlDelegate?
}
