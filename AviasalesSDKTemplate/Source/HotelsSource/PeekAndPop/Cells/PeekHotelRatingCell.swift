class PeekHotelRatingCell: PeekTableCell {

    @IBOutlet private weak var hotelInfoView: HLHotelInfoView?

    override func awakeFromNib() {
        super.awakeFromNib()
        hotelInfoView?.style = .peek
    }

    override func configure(_ item: PeekItem) {
        super.configure(item)

        hotelInfoView?.hotel = item.variant.hotel
    }
}
