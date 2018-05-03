import SDWebImage

@objcMembers
class HLPhotoView: UIView, CAAnimationDelegate {

    let overlayAnimationDuration: TimeInterval = 0.1

    fileprivate(set) var imageView: UIImageView!
    fileprivate(set) var progressView: HLProgressView!
    fileprivate(set) var url: URL?
    fileprivate(set) var placeholderImage: UIImage?
    fileprivate var overlayView: UIView!

    fileprivate var timer: Timer?

    static var canAnimatePhotoAppearance = true

    var needShowProgressView: Bool = true {
        didSet {
            if !needShowProgressView && !(progressView?.isHidden ?? true) {
                progressView?.stopAnimating()
            }
        }
    }
    var needShowPlaceholderWhileLoading: Bool = false

    var placeholderContentMode: UIViewContentMode = UIViewContentMode.center {
        didSet {
            if self.image == self.placeholderImage {
                self.imageView?.contentMode = self.placeholderContentMode
            }
        }
    }

    var imageContentMode: UIViewContentMode = UIViewContentMode.scaleAspectFill {
        didSet {
            if self.image != self.placeholderImage {
                self.imageView?.contentMode = self.imageContentMode
            }
        }
    }

    var image: UIImage? {
        get {
            return self.imageView?.image
        }

        set(newValue) {
            self.setImage(newValue, needDelay: false, animated: false)
        }
    }

    // MARK: - Override methods

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: HLPhotoManagerNotifications.DownloadWillStart), object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.initialize()
    }

    // MARK: - Internal methods

    func setupImage(_ image: UIImage?) {
        reset()

        progressView.stopAnimating()
        progressView.updateProgress(0.0)

        imageView.contentMode = (image == placeholderImage) ? placeholderContentMode : imageContentMode
        imageView.image = image
    }

    func reset() {
        HLPhotoManager.sharedManager.stopObserve(self)

        self.timer?.invalidate()
        self.timer = nil

        self.imageView.layer.removeAllAnimations()
    }

    func setImage(_ image: UIImage?, needDelay: Bool, animated: Bool) {
        reset()

        if !progressView.isHidden && needShowProgressView {
            progressView.updateProgress(1.0)
        }

        let delay = needDelay ? 0.2 : 0.0
        var userInfo: [String : AnyObject] = ["animated" : animated as AnyObject]
        if let img = image {
            userInfo["image"] = img
        }

        self.timer = Timer(timeInterval: delay, target: self, selector: #selector(HLPhotoView.onTimer(_:)), userInfo: userInfo, repeats: false)
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
    }

    func setImage(url: URL, placeholder: UIImage?, animated: Bool) {
        let img = self.needShowPlaceholderWhileLoading ? placeholder : nil
        self.setupImage(img)

        self.url = url
        self.placeholderImage = placeholder

        HLPhotoManager.sharedManager.downloadImage(url: url, target: self)
    }

    func showOverlayViewAnimated(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: overlayAnimationDuration, animations: { () -> Void in
                self.overlayView.alpha = 0.3
            })
        } else {
            self.overlayView.alpha = 0.3
        }
    }

    func hideOverlayViewAimated(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: overlayAnimationDuration, animations: { () -> Void in
                self.overlayView.alpha = 0
            })
        } else {
            self.overlayView.alpha = 0
        }
    }

    func initialize() {
        self.addImageView()
        addProgressView()
        self.addOverlayView()

        self.layer.contentsGravity = kCAGravityCenter
        self.layer.masksToBounds = true

        let notificationName = NSNotification.Name(rawValue: HLPhotoManagerNotifications.DownloadWillStart)
        NotificationCenter.default.addObserver(self, selector: #selector(HLPhotoView.photoDownloadWillStart(_:)), name: notificationName, object: nil)
    }

    // MARK: - Private methods

    fileprivate func animateImageChanges(_ duration: TimeInterval) {
        self.imageView.layer.removeAllAnimations()

        if duration > 0.0 {
            let transition = CATransition()
            transition.delegate = self
            transition.duration = duration
            transition.isRemovedOnCompletion = true
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.imageView.layer.add(transition, forKey: "fadeImageAnimation")
        }
    }

    private func addProgressView() {
        progressView = HLProgressView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.hidesWhenStopped = true
        progressView.stopAnimating()
        addSubview(progressView)
        progressView.autoSetDimensions(to: CGSize(width: 100.0, height: 100.0))
        progressView.autoCenterInSuperview()
    }

    fileprivate func addImageView() {
        self.imageView = UIImageView()
        self.imageView.frame = self.bounds
        self.imageView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.addSubview(self.imageView)
    }

    fileprivate func addOverlayView() {
        self.overlayView = UIView()
        self.overlayView.backgroundColor = UIColor.black
        self.overlayView.frame = self.bounds
        self.overlayView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.hideOverlayViewAimated(false)
        self.addSubview(self.overlayView)
    }

}

extension HLPhotoView {

    @objc fileprivate func photoDownloadWillStart(_ notification: Notification) {
        if let url1 = (notification.userInfo?["url"] as? URL), let url2 = self.url, (url1 == url2) {
            if progressView.isHidden && needShowProgressView {
                progressView.startAnimating()
            }
        }
    }
}

extension HLPhotoView {

    @objc fileprivate func onTimer(_ timer: Timer) {
        guard let userInfoDict = timer.userInfo as? [String: Any] else {
            return
        }

        let animated = (userInfoDict["animated"] as? Bool) ?? false
        let duration = animated ? 0.2 : 0.0
        let image = userInfoDict["image"] as? UIImage

        self.setupImage(image)
        self.animateImageChanges(duration)

    }

}

extension HLPhotoView: HLSmartPhotoManagerDelegate {

    func imageDownloadingProgress(_ url: URL, progress: CGFloat) {
        hl_dispatch_main_async_safe({ [weak self] () -> Void in
            guard let `self` = self else { return }

            if self.progressView.isHidden && self.needShowProgressView {
                self.progressView.startAnimating()
            }

            if self.needShowProgressView {
                self.progressView.updateProgress(progress)
            }
        })
    }

    func imageDownloadingCompleted(_ image: UIImage?, url: URL!, success: Bool, cacheType: SDImageCacheType) {
        hl_dispatch_main_async_safe({ [weak self] () -> Void in
            guard let `self` = self else { return }

            let needDelay = !self.progressView.isHidden && self.needShowProgressView && cacheType != .memory && HLPhotoView.canAnimatePhotoAppearance
            let animated = cacheType != .memory && HLPhotoView.canAnimatePhotoAppearance
            let img = image ?? self.placeholderImage

            self.setImage(img, needDelay: needDelay, animated: animated)
            self.setImage(img, needDelay: false, animated: animated)
        })
    }

}
