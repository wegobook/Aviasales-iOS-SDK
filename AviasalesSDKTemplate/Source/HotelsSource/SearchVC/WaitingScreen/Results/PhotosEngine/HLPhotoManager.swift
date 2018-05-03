import SDWebImage

@objcMembers
class HLPhotoManager: NSObject {

    typealias ProgressBlock = (_ progress: CGFloat) -> Void
    typealias CompletionBlock = (_ image: UIImage?, _ url: URL?, _ success: Bool, _ cacheType: SDImageCacheType) -> Void

    fileprivate var downloadsPool: [URL : DownloadObject] = [:]
    fileprivate(set) var imageManager: SDWebImageManager!

    fileprivate let queue = DispatchQueue(label: "ru.hotellook.app.photo_manager", attributes: [])

    static let sharedManager = HLPhotoManager()

    // MARK: - Override methods

    fileprivate override init() {
        super.init()

        self.imageManager = SDWebImageManager()
        self.imageManager.delegate = self
    }

    // MARK: - Internal methods

    func isAlreadyCached(_ url: URL) -> Bool {
        return self.imageManager.cachedImageExists(for: url)
    }

    func imageFromMemoryCached(_ url: URL) -> UIImage? {
        let key = self.imageManager.cacheKey(for: url)

        return self.imageManager.imageCache.imageFromMemoryCache(forKey: key)
    }

    func imageFromDiskCached(_ url: URL) -> UIImage? {
        let key = self.imageManager.cacheKey(for: url)

        return self.imageManager.imageCache.imageFromDiskCache(forKey: key)
    }

    func downloadImage(url: URL, progress: ProgressBlock?, completed: CompletionBlock?) -> SDWebImageOperation {

        return self.imageManager.downloadImage(with: url, options: [SDWebImageOptions.retryFailed, SDWebImageOptions.continueInBackground],
            progress: { (receivedSize: Int, expectedSize: Int) -> Void in
                let percent = CGFloat(receivedSize) / CGFloat(expectedSize)
                progress?(percent)
            },
            completed: { (image, error, cacheType, finished, url) in
                let success = (image != nil) && (error == nil) && finished

                completed?(image, url, success, cacheType)
        })
    }

    func cancelAll() {
        imageManager.cancelAll()
    }

//    class var defaultHotelPhotoSize: CGSize {
//        if iPad() {
//            let scale = UIScreen.main.scale
//            let width = (scale == 1.0) ? 1024.0 : 718.0
//            let height = (scale == 1.0) ? 768.0 : 460.0
//            return CGSize(width: width, height: height)
//        } else {
//            let width: CGFloat = UIScreen.main.bounds.width
//            var height: CGFloat = 170.0
//            if iPhone4Inch() {
//                height = 193.0
//            } else if iPhone47Inch() {
//                height = 225.0
//            } else if iPhone55Inch() {
//                height = 250.0
//            }
//            return CGSize(width: width, height: height)
//        }
//    }
}

// MARK: - Smartly image downloading

protocol HLSmartPhotoManagerDelegate: class {

    func imageDownloadingProgress(_ url: URL, progress: CGFloat)
    func imageDownloadingCompleted(_ image: UIImage?, url: URL!, success: Bool, cacheType: SDImageCacheType)

}

extension HLPhotoManager {

    fileprivate class DelegateObject: NSObject {

        weak var target: HLSmartPhotoManagerDelegate?

        init(target: HLSmartPhotoManagerDelegate) {
            super.init()

            self.target = target
        }

    }

    fileprivate class DownloadObject: NSObject {

        var delegates: [DelegateObject] = []
        var operation: SDWebImageOperation!
        var progress: CGFloat = 0.0

        init(target: HLSmartPhotoManagerDelegate?) {
            super.init()

            self.addDelegate(target)
        }

        func addDelegate(_ target: HLSmartPhotoManagerDelegate?) {
            if let obj = target {
                if !self.containCallback(obj) {
                    let delegate = DelegateObject(target: obj)
                    self.delegates.append(delegate)
                }
            }
        }

        func containCallback(_ obj: AnyObject) -> Bool {
            for delegateObj in self.delegates where delegateObj.target === obj {
                return true
            }
            return false
        }

    }

    fileprivate typealias DecompressCompletionBlock = (_ decompressedImage: UIImage?) -> Void

    // MARK: - Internal methods

    func downloadImage(url: URL, target: HLSmartPhotoManagerDelegate?) {

        if let t = target {
            self.stopObserve(t)
        }

        self.queue.async { [weak self] in
            guard let `self` = self else { return }
            self.startDownloadImage(url, target: target)
        }
    }

    func stopObserve(_ target: HLSmartPhotoManagerDelegate) {
        self.queue.async { [weak self] in
            guard let `self` = self else { return }

            var urlsToRemove: [URL] = []

            for (url, downloadObject) in self.downloadsPool {
                var delegateToRemove: DelegateObject?
                for delegate in downloadObject.delegates {
                    if delegate.target === target {
                        delegateToRemove = delegate

                        break
                    }
                }

                if let delegate = delegateToRemove {
                    downloadObject.delegates.removeObject(delegate)
                    if downloadObject.delegates.count == 0 {
                        downloadObject.operation.cancel()
                        urlsToRemove.append(url)
                    }
                }
            }

            for url in urlsToRemove {
                self.downloadsPool.removeValue(forKey: url)
            }
        }
    }

    func cancelAllDownloadsWithoutCallbacks() {
        self.queue.async { [weak self] in
            guard let `self` = self else { return }

            var urlsToRemove: [URL] = []
            for (url, downloadObject) in self.downloadsPool where downloadObject.delegates.count == 0 {
                downloadObject.operation.cancel()
                urlsToRemove.append(url)
            }

            for url in urlsToRemove {
                self.downloadsPool.removeValue(forKey: url)
            }
        }
    }

    // MARK: - Private methods

    fileprivate func startDownloadImage(_ url: URL, target: HLSmartPhotoManagerDelegate?) {
        if let downloadObject = downloadsPool[url] {
            downloadObject.addDelegate(target)
            notifyDelegatesOfProgress(url, progress: downloadObject.progress)
        } else {
            let downloadObject = DownloadObject(target: target)
            self.downloadsPool[url] = downloadObject

            downloadObject.operation = self.downloadImage(url: url,
                progress: { [weak self] (progress) -> Void in
                    self?.notifyDelegatesOfProgress(url, progress: progress)
                },
                completed: { [weak self] (image, url, success, cacheType) -> Void in
                    self?.decompressImage(image, completion: { (decompressedImage) -> Void in
                        self?.notifyDelegatesOfCompletion(decompressedImage, url: url, success: success, cacheType: cacheType)
                    })
            })
        }
    }

    fileprivate func notifyDelegatesOfProgress(_ url: URL, progress: CGFloat) {
        self.queue.async { [weak self] in
            guard let `self` = self else { return }

            if let downloadObject = self.downloadsPool[url] {
                downloadObject.progress = progress

                for delegate in downloadObject.delegates {
                    if let target = delegate.target {
                        target.imageDownloadingProgress(url, progress: progress)
                    }
                }
            }
        }
    }

    fileprivate func notifyDelegatesOfCompletion(_ image: UIImage?, url: URL!, success: Bool, cacheType: SDImageCacheType) {
        self.queue.async { [weak self] in
            guard let `self` = self else { return }

            if let downloadObject = self.downloadsPool[url] {
                for delegate in downloadObject.delegates {
                    if let target = delegate.target {
                        target.imageDownloadingCompleted(image, url: url, success: success, cacheType: cacheType)
                    }
                }

                self.downloadsPool.removeValue(forKey: url)
            }
        }
    }

    fileprivate func decompressImage(_ image: UIImage?, completion: @escaping DecompressCompletionBlock) {
        if let img = image {

            let queue = DispatchQueue.global()
            queue.async(execute: {
                UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
                img.draw(at: CGPoint.zero)
                let decompressedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                completion(decompressedImage)
            })
        } else {
            completion(image)
        }
    }

}

// MARK: - SDWebImageManagerDelegate and Notification methods

struct HLPhotoManagerNotifications {

    static let DownloadWillStart = "HLPhotoManagerNotificationsIdentifierDownloadWillStart"
}

extension HLPhotoManager: SDWebImageManagerDelegate {

    func imageManager(_ imageManager: SDWebImageManager!, shouldDownloadImageFor imageURL: URL!) -> Bool {
        notifyDelegatesOfProgress(imageURL, progress: 0.0)
        NotificationCenter.default.post(name: Notification.Name(rawValue: HLPhotoManagerNotifications.DownloadWillStart), object: nil, userInfo: ["url" : imageURL])

        return true
    }
}
