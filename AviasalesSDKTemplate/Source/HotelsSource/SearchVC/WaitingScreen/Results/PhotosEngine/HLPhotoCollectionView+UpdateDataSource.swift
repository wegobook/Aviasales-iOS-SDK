extension HLPhotoCollectionView {

    func updateDataSource(withHotel hotel: HDKHotel, imageSize: CGSize, thumbSize: CGSize, useThumbs: Bool) {
        if useThumbs {
            self.thumbs = HLUrlUtils.photoUrls(by: hotel, withSizeInPoints: thumbSize) as! [URL]
        }
        self.updateDataSource(withHotel: hotel, imageSize: imageSize)
    }

    func updateDataSource(withHotel hotel: HDKHotel, imageSize: CGSize, useThumbs: Bool) {
        updateDataSource(withHotel: hotel, imageSize: imageSize, thumbSize: HLPhotoManager.defaultThumbPhotoSize, useThumbs: useThumbs)
    }

    func updateDataSource(withHotel hotel: HDKHotel, imageSize: CGSize, firstImage: UIImage? = nil) {
        if hotel.photosIds.count > 0 {
            var content = HLUrlUtils.photoUrls(by: hotel, withSizeInPoints: imageSize)
            if let img = firstImage {
                content[0] = img
            }

            self.content = content as [AnyObject]
        } else {
            self.content = [UIImage.photoPlaceholder]
        }

        self.collectionView.reloadData()
    }

}
