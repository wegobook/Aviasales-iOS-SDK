class HLProgressView: UIView, CAAnimationDelegate {

    override var frame: CGRect {
        didSet {
            initialize()
        }
    }

    var hidesWhenStopped: Bool = false
    var progress: CGFloat = 0.0

    var startAngle: CGFloat = -(CGFloat)(Double.pi / 2) {
        didSet {
            backgroundLayer?.path = createPath(borderRadius, startAngle: startAngle).cgPath
        }
    }

    var borderRadius: CGFloat = 16.0 {
        didSet {
            backgroundLayer?.path = createPath(self.borderRadius, startAngle: startAngle).cgPath
        }
    }

    var progressRadius: CGFloat = 15.0 {
        didSet {
            progressLayer?.path = createPath(progressRadius, startAngle: startAngle).cgPath
        }
    }

    var borderLineWidth: CGFloat = 0.0 {
        didSet {
            backgroundLayer?.lineWidth = borderLineWidth
        }
    }

    var progressLineWidth: CGFloat = 2.0 {
        didSet {
            progressLayer?.lineWidth = progressLineWidth
        }
    }

    var borderColor: UIColor = JRColorScheme.photoActivityIndicatorBorderColor() {
        didSet {
            backgroundLayer?.strokeColor = borderColor.cgColor
        }
    }

    var backgroundLayerColor: UIColor = JRColorScheme.photoActivityIndicatorBackgroundColor() {
        didSet {
            backgroundLayer?.fillColor = backgroundLayerColor.cgColor
        }
    }

    var progressLineColor: UIColor = JRColorScheme.darkBackgroundColor() {
        didSet {
            progressLayer?.strokeColor = progressLineColor.cgColor
        }
    }

    fileprivate var progressLayer: CAShapeLayer!
    fileprivate var backgroundLayer: CAShapeLayer!

    fileprivate var layerContentsScale: CGFloat {
        return UIScreen.main.scale * 3.0
    }

    // MARL: - Override methods

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }

    // MARL: - Override methods

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    // MARK: - Internal methods

    func updateProgress(_ progress: CGFloat) {
        if progress == 0.0 {
            resetProgress()
        } else {
            progressLayer.strokeEnd = progress
            self.progress = progress
        }
    }

    func startAnimating() {
        resetProgress()
        startSpinAnimation()
        isHidden = false
    }

    func stopAnimating() {
        isHidden = hidesWhenStopped
    }

    func initialize() {
        self.initializeBackgroundLayer()
        self.initializeProgressLayer()

        self.layer.contentsScale = self.layerContentsScale
        self.layer.rasterizationScale = self.layerContentsScale
        self.resetProgress()
    }

    // MARK: - Private methods

    fileprivate func initializeBackgroundLayer() {
        if let border = self.backgroundLayer {
            border.removeFromSuperlayer()
        }

        let path = createPath(borderRadius, startAngle: startAngle)
        backgroundLayer = CAShapeLayer()
        backgroundLayer.path = path.cgPath
        backgroundLayer.strokeColor = borderColor.cgColor
        backgroundLayer.fillColor = backgroundLayerColor.cgColor
        backgroundLayer.lineWidth = borderLineWidth
        backgroundLayer.strokeStart = 0.0
        backgroundLayer.strokeEnd = 1.0
        backgroundLayer.lineCap = kCALineCapRound
        backgroundLayer.rasterizationScale = layerContentsScale
        backgroundLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(backgroundLayer)
    }

    fileprivate func initializeProgressLayer() {
        if let progress = progressLayer {
            progress.removeFromSuperlayer()
        }

        let path = createPath(progressRadius, startAngle: startAngle)
        progressLayer = CAShapeLayer()
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = progressLineColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = progressLineWidth
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = kCALineCapRound
        progressLayer.rasterizationScale = layerContentsScale
        progressLayer.contentsScale = UIScreen.main.scale
        progressLayer.isOpaque = false
        layer.addSublayer(progressLayer)
    }

    fileprivate func resetProgress() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let strokeEnd = progressLineWidth / (2.0 * progressRadius * CGFloat.pi)
        progress = 0.0
        layer.transform = CATransform3DIdentity
        progressLayer.strokeEnd = strokeEnd

        CATransaction.commit()
    }

    fileprivate func createPath(_ radius: CGFloat, startAngle: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + 2.0 * CGFloat.pi, clockwise: true)
        path.lineJoinStyle = CGLineJoin.miter
        path.miterLimit = 360
        path.flatness = 0.5

        return path
    }

    fileprivate func nowSpining() -> Bool {
        if let animationKeys = self.layer.animationKeys() {
            return animationKeys.contains("spinAnimation")
        }

        return false
    }

    fileprivate func startSpinAnimation() {
        if !self.nowSpining() {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = NSNumber(value: Double.pi * 0.2)
            rotationAnimation.duration = 0.2
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = Float.infinity
            rotationAnimation.isRemovedOnCompletion = false
            self.layer.add(rotationAnimation, forKey: "spinAnimation")
        }
    }

    fileprivate func completeSpinAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: 0.0)
        rotationAnimation.duration = 0.2
        rotationAnimation.delegate = self

        self.layer.removeAnimation(forKey: "spinAnimation")
        self.layer.add(rotationAnimation, forKey: "completeSpinAnimation")
    }

}
