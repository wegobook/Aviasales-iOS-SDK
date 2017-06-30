class PeekFullInfoCell: PeekTableCell {

    @IBOutlet var addressLabel: UILabel?
    @IBOutlet var hotelInfoView: HLHotelInfoView?
    @IBOutlet var hotelPhoto: HLPhotoView?

    override func configure(_ item: PeekItem) {
        super.configure(item)

        addressLabel?.text = item.variant.hotel.address
        hotelInfoView?.style = .peek
        hotelInfoView?.hotel = item.variant.hotel
        if let size = hotelPhoto?.frame.size {
            let url = HLUrlUtils.firstHotelPhotoURL(by: item.variant.hotel, withSizeInPoints: size)
            hotelPhoto?.setImage(url: url, placeholder: UIImage.photoPlaceholder, animated: false)
        }
    }
}
