class PeekPhotoCell: PeekTableCell {

    @IBOutlet weak var photoView: HLPhotoView?
    var variant: HLResultVariant?
    var photoIndex: Int = 0

    override func layoutSubviews() {
        super.layoutSubviews()

        loadHotelPhoto()
    }

    func loadHotelPhoto() {
        guard let variant = self.variant else { return }
        guard let photoView = self.photoView else { return }

        if variant.hotel.photosIds.count > 0 {
            photoView.imageContentMode = .scaleAspectFill
            let photoSize = CGSize(width: UIScreen.main.bounds.width, height: HLPhotoScrollView.preferredHeight())
            let url = HLUrlUtils.photoURL(by: variant.hotel, size: photoSize, index: photoIndex)
            photoView.setImage(url: url, placeholder: nil, animated: true)
        }
    }

    override func configure(_ item: PeekItem) {
        super.configure(item)

        self.variant = item.variant
        if let photoItem = item as? PhotoPeekItem {
            self.photoIndex = photoItem.photoIndex
        }
    }
}
