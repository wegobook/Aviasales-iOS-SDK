extension HLPhotoManager {

    class var defaultCityPhotoSize: CGSize {
        if iPhone() {
            let width = UIScreen.main.bounds.width
            if iPhone4Inch() {
                return CGSize(width: width, height: 194.0)
            }
            if iPhone47Inch() {
                return CGSize(width: width, height: 267.0)
            }
            if iPhone55Inch() {
                return CGSize(width: width, height: 335.0)
            }
            return CGSize(width: width, height: 147.0)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }

    class func calculateThumbSizeForColumnsCount(_ columnsCount: Int, containerWidth: CGFloat) -> CGSize {
        guard columnsCount > 0 else { return CGSize.zero }

        let width = ceil(containerWidth / CGFloat(columnsCount))
        let height = width

        return CGSize(width: width, height: height)
    }

    class var defaultThumbPhotoSize: CGSize {
        let ratio = HLPhotoManager.defaultHotelPhotoSize.width / HLPhotoManager.defaultHotelPhotoSize.height
        let height = iPad() ? CGFloat(160.0) : CGFloat(80.0)
        let width = ratio * height

        return CGSize(width: width, height: height)
    }

    class var defaultHotelPhotoSize: CGSize {
        if iPad() {
            let scale = UIScreen.main.scale
            let width = (scale == 1.0) ? 1024.0 : 718.0
            let height = (scale == 1.0) ? 768.0 : 460.0
            return CGSize(width: width, height: height)
        } else {
            let width: CGFloat = UIScreen.main.bounds.width
            var height: CGFloat = 170.0
            if iPhone4Inch() {
                height = 193.0
            } else if iPhone47Inch() {
                height = 225.0
            } else if iPhone55Inch() {
                height = 250.0
            }
            return CGSize(width: width, height: height)
        }
    }
}

// MARK: - Hotel Additions

extension HLPhotoManager {

    func loadThumbs(forHotel hotel: HDKHotel) {
        let urls = HLUrlUtils.photoUrls(by: hotel, withSizeInPoints: HLPhotoManager.defaultThumbPhotoSize)
        for url in urls {
            HLPhotoManager.sharedManager.downloadImage(url: url as! URL, target: nil)
        }
    }

}
