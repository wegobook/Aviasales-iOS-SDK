@objcMembers
class HLDiscountHotelBadge: HLPopularHotelBadge {

    init(discount: Int) {
        super.init()

        self.name = StringUtils.discountString(forDiscount: discount)
        self.systemName = StringUtils.discountString(forDiscount: discount)
        self.color = JRColorScheme.discountColor()
    }
}
