import UIKit

class DiscountCell: HLHotelDetailsTableCell {
    private var discountInfoView = DiscountInfoView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(discountInfoView)
        discountInfoView.autoPinEdgesToSuperviewEdges()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for room: HDKRoom, currency: HDKCurrency, duration: Int) {
        discountInfoView.configure(for: room, currency: currency, duration: duration)
    }

    class func preferredHeight(width: CGFloat, room: HDKRoom, currency: HDKCurrency, duration: Int) -> CGFloat {
        return DiscountInfoView.preferredHeight(containerWidth: width, room: room, currency: currency, duration: duration)
    }
}
