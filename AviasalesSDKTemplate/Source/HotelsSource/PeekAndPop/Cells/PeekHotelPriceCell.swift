class PeekHotelPriceCell: HLPriceTableViewCell {

    override var canHighlightDiscount: Bool {
        return true
    }

    func configure(_ item: PeekItem) {
        layoutIfNeeded()
        canHighlightPrivatePrice = true
        if let priceItem = item as? PricePeekItem, let room = priceItem.room {
            configure(for: room, currency: item.variant.searchInfo.currency, duration: item.variant.duration)
        }
    }
}
