typealias EditingChangedBlock = (_ nowEditing: Bool) -> Void

class HLZoomablePhotoView: HLPhotoView {

    fileprivate let placeholder = UIImage(named:"hotelPhotoPlaceholder")
    fileprivate var doubleTapGestureRecognizer: UITapGestureRecognizer!
    fileprivate var scrollView: UIScrollView!

    var editingChangedHandler: EditingChangedBlock?
    var needFill: Bool = false

    var zoomEnabled: Bool = false {
        didSet {
            self.scrollView.isUserInteractionEnabled = self.zoomEnabled
            self.doubleTapGestureRecognizer.isEnabled = self.zoomEnabled
        }
    }

    var isZoomed: Bool {
        return self.scrollView.zoomScale > 1.0
    }

    // MARK: - Override methods

    override func layoutSubviews() {
        super.layoutSubviews()

        self.setZoomScalesLimitsForCurrentBounds()
    }

    override func setupImage(_ image: UIImage?) {
        super.setupImage(image)

        self.setZoomScalesLimitsForCurrentBounds()
    }

    override func initialize() {
        super.initialize()

        self.addScrollView()

        self.imageView.removeFromSuperview()
        self.scrollView.addSubview(self.imageView)
        self.bringSubview(toFront: self.progressView)

        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HLZoomablePhotoView.onDoubleTap(_:)))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.doubleTapGestureRecognizer.isEnabled = self.zoomEnabled
        self.addGestureRecognizer(self.doubleTapGestureRecognizer)
    }

    // MARK: - Private methods

    fileprivate func addScrollView() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.delegate = self
        self.scrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.scrollView.isUserInteractionEnabled = self.zoomEnabled
        self.scrollView.layer.contentsGravity = kCAGravityCenter
        self.addSubview(self.scrollView)
    }

    fileprivate func setZoomScalesLimitsForCurrentBounds() {
        self.scrollView.maximumZoomScale = 1
        self.scrollView.minimumZoomScale = 1
        self.scrollView.zoomScale = 1

        if let img = self.image, !img.size.equalTo(CGSize.zero) {
            let xScale = self.bounds.width / img.size.width
            let yScale = self.bounds.height / img.size.height
            let maxScale = CGFloat(4)
            var minScale = self.needFill ? max(xScale, yScale) : min(xScale, yScale)
            var contentSize = img.size

            if img == self.placeholder {
                minScale = 1.0
                contentSize = self.bounds.size
            }

            self.imageView.frame = CGRect(x: 0.0, y: 0.0, width: img.size.width, height: img.size.height)
            self.imageView.center = CGPoint(x: self.scrollView.bounds.width / 2.0, y: self.scrollView.bounds.height / 2.0)
            self.scrollView.contentSize = contentSize
            self.scrollView.maximumZoomScale = maxScale
            self.scrollView.minimumZoomScale = minScale
            self.scrollView.zoomScale = minScale

            let width = img.size.width * self.scrollView.zoomScale
            let height = img.size.height * self.scrollView.zoomScale
            let x = (width > self.bounds.width) ? (width - self.bounds.width) : CGFloat(0.0)
            let y = (height > self.bounds.height) ? (height - self.bounds.height) : CGFloat(0.0)

            self.scrollView.contentOffset = CGPoint(x: x / 2.0, y: y / 2.0)
            self.scrollView.isScrollEnabled = false
        }
    }

    @objc fileprivate func onDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let img = self.image, !img.size.equalTo(CGSize.zero) else { return }

        let xScale = self.bounds.width / self.image!.size.width
        let yScale = self.bounds.height / self.image!.size.height
        let maxScale = max(xScale, yScale)
        let minScale = min(xScale, yScale)

        let size = self.scrollView.bounds.size
        let zoom = (self.scrollView.zoomScale != minScale) ? minScale : maxScale

        var point = gestureRecognizer.location(in: self.imageView)
        point.x = (zoom == minScale) ? 0.0 : point.x
        point.y = (zoom == minScale) ? 0.0 : point.y

        let w = size.width / zoom
        let h = size.height / zoom
        let x = point.x - w / 2.0
        let y = point.y - h / 2.0

        self.scrollView.zoom(to: CGRect(x: x, y: y, width: w, height: h), animated: true)
    }

}

// MARK: - UIScrollViewDelegate methods

extension HLZoomablePhotoView: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let zoomView = self.viewForZooming(in: scrollView)!

        if zoomView.frame.width < scrollView.bounds.width {
            zoomView.frame.origin.x = (scrollView.bounds.width - zoomView.frame.width) / 2.0
        } else {
            zoomView.frame.origin.x = 0.0
        }

        if zoomView.frame.height < scrollView.bounds.height {
            zoomView.frame.origin.y = (scrollView.bounds.height - zoomView.frame.height) / 2.0
        } else {
            zoomView.frame.origin.y = 0.0
        }

        if scrollView.zoomScale == scrollView.minimumZoomScale {
            editingChangedHandler?(false)
            scrollView.isScrollEnabled = false
        } else {
            editingChangedHandler?(true)
            scrollView.isScrollEnabled = true
        }
    }

}
